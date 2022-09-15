
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021

`define NUM_BALLS 6 
`define NUM_BALL_FLAGS 2 // +1 for real num of flags is [NUM_BALL_FLAGS:0]
`define NUM_FLAGS_BITS 1 // array of 2.. // +1 : max num of bits to represent all flags ( log(NUM_BALL_FLAGS+1) ) 


module	hit_unit	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	cheat,
			
			input	logic	[1:0] Table_DR,
			input	logic	[`NUM_BALLS:0] Balls_DR_VEC,
			input logic Hole_DR, // small hole
			input logic [2:0] Hole_ID,
			

			output logic collision, // active in case of collision between two objects

			output logic [`NUM_BALLS:0] balls_in_game, 
			output logic [`NUM_BALLS:0] balls_collide,
			output logic [`NUM_BALLS:0] ballhole_collide,
			output logic [`NUM_BALLS:0] ballwall_collide,
			output logic [1:0] collided_wall,
			output logic [1:0][3:0] Balls_col_ID  


);




logic [`NUM_BALLS:0] zeroVec;
assign zeroVec = {(`NUM_BALLS+1){1'b0}};

logic [`NUM_BALLS:0] oneVec;
assign oneVec = {(`NUM_BALLS+1){1'b1}};



logic collision_BallWall;
logic collision_BallHole;
logic collision_BallBall;
assign collision = collision_BallWall || collision_BallBall;
assign collision_BallWall = ( (Table_DR != 2'b00) && (Balls_DR_VEC != zeroVec) ); 
assign collision_BallHole = ( (Hole_DR) && (Balls_DR_VEC != zeroVec) );
assign collision_BallBall = ( (Balls_DR_VEC != zeroVec) && ( (^Balls_DR_VEC) == 1'b0 ) ); 


logic [`NUM_BALL_FLAGS:0][`NUM_BALLS+1:0] ballsFlag; 
logic [`NUM_BALL_FLAGS:0][1:0] SOF_ball_counter ;
logic wallsFlag;
logic SOF_wall_counter ;
logic holesFlag; // a semaphore to set the output only once per frame / regardless of the number of collisions 

logic flagMatch; 			//check if ok
logic flagSpotFound;
logic [`NUM_FLAGS_BITS:0] putFlagIdx;		

logic ball_col_num ;
localparam SOF_ball_counter_MAX_VALUE = 2'b10 ;
localparam Bflag_MSB = `NUM_BALLS+1;
localparam Bflag_SIZE = `NUM_BALLS+2;



always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		holesFlag	<= 1'b0;
		ballsFlag <= {(`NUM_BALL_FLAGS+1){1'b0,zeroVec[`NUM_BALLS:0]}};	// n+2 zeros in a row	
		SOF_ball_counter <= {(`NUM_BALL_FLAGS+1){2'b0}};
		wallsFlag <= 1'b0;
		SOF_wall_counter <= 1'b0;
		flagMatch = 1'b0;
		flagSpotFound = 1'b0;
		putFlagIdx = {(`NUM_FLAGS_BITS+1){1'b0}};
		
		balls_in_game <= oneVec ;
		balls_collide <= zeroVec ;
		ballhole_collide <= zeroVec;
		ballwall_collide <= zeroVec;
		collided_wall <= 2'b00;
		Balls_col_ID <= {2{4'b0000}};

	end 
	
	else begin 
		

		ballhole_collide <= zeroVec;
		ballwall_collide <= zeroVec ;
		collided_wall <= 2'b00;
		Balls_col_ID <= {2{4'b0000}};  
		balls_collide <= zeroVec ;
		flagMatch = 1'b0;
		flagSpotFound = 1'b0;
		putFlagIdx = {(`NUM_FLAGS_BITS+1){1'b0}};
		
		if(startOfFrame) 
			begin
				for (int i=0; i < `NUM_BALL_FLAGS+1 ; i++)
					begin
						if ( SOF_ball_counter[i] == SOF_ball_counter_MAX_VALUE )
							begin
								ballsFlag[i] <= {(Bflag_SIZE){1'b0}}; //working? YES!
								SOF_ball_counter[i] <= 2'b00;
							end
						else if ( ballsFlag[i][Bflag_MSB] == 1'b1 )
							begin
								SOF_ball_counter[i] <= SOF_ball_counter[i] + 2'b01;
							end
					end
				
			if ( SOF_wall_counter == 1'b1 )
				begin
					wallsFlag <= 1'b0;
					SOF_wall_counter <= 1'b0;
				end
			else if ( wallsFlag == 1'b1 )
				begin
					SOF_wall_counter <= 1'b1;
				end
			if ( holesFlag == 1'b1 )
				begin
					holesFlag <= 1'b0;
				end
			end
			
		if ( cheat ) // remove the first ball!
			begin	
				for (int ballID = 1; ballID < `NUM_BALLS + 1 ; ballID++)
					begin
						if( balls_in_game[ballID] == 1'b1)
							begin
								balls_in_game[ballID] <= 1'b0; // remove the first ball!
								break;
							end
					end
			end
			
		if ( collision_BallHole  && (holesFlag == 1'b0)) 
			begin 
				holesFlag	<= 1'b1; // to enter only once 
				//out_collision_BallHole <= 1'b1; 
				balls_in_game <= (balls_in_game) & (~Balls_DR_VEC) ;
				ballhole_collide <= Balls_DR_VEC;
			end

		if ( collision_BallBall ) 
			begin
				flagMatch = 1'b0;
				flagSpotFound = 1'b0;
				putFlagIdx = {(`NUM_FLAGS_BITS+1){1'b0}};
				for (int i=0; i < (`NUM_BALL_FLAGS+1) ; i++)
				begin
					if (ballsFlag[i][`NUM_BALLS:0] == Balls_DR_VEC[`NUM_BALLS:0] )
					begin
						flagMatch = 1'b1;
						break;
					end
					else if ( flagMatch != 1'b1 && flagSpotFound == 1'b0 && ballsFlag[i][Bflag_MSB] == 1'b0 )
					begin
						putFlagIdx = i[`NUM_FLAGS_BITS:0]; // locate as flag i
						flagSpotFound = 1'b1;
					end
				end
				
				if (flagMatch == 1'b0 && flagSpotFound == 1'b1) // match not fount and spot found
				begin
					balls_collide <= Balls_DR_VEC;
					ballsFlag[putFlagIdx]	<= {1'b1,Balls_DR_VEC[`NUM_BALLS:0]}; // 1 for activated,  
					ball_col_num = 1'b0;	
					for (int ballID = 0; ballID < `NUM_BALLS+1 ; ballID++)
						begin
							if(Balls_DR_VEC[ballID] == 1'b1)
							begin
								Balls_col_ID[ball_col_num] <= ballID; 
								if(ball_col_num == 1'b1)
									break;
								ball_col_num = 1'b1;
							end
						end
					end
			end 

		if ( collision_BallWall  && (wallsFlag == 1'b0)) 
			begin 
				wallsFlag <= 1'b1; // to enter only once 
				//out_collision_BallWall <= 1'b1; 
				//ballwall_collide[] <= Balls_DR_VEC;
				ballwall_collide <= Balls_DR_VEC;
				collided_wall <= Table_DR;
			end 
	end 
end

endmodule
