
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021

`define NUM_BALLS 2 

module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			//input	logic	WhiteBall_DR,
			input	logic	[1:0] Table_DR,
			input	logic	[`NUM_BALLS:0] Balls_DR_VEC,
			input logic Hole_DR, // small hole
			input logic [2:0] Hole_ID,
			
			//input logic signed [`NUM_BALLS:0] Balls_X_Speed [10:0], // ***check here what is signed and what is unsigned***
			//input logic signed [`NUM_BALLS:0] Balls_Y_Speed [10:0], // ***NUMBALLS - unsigned,    10:0 - signed***

			//input	logic	drawing_request_hole_1,
			// add input from box of numbers here 		
			output logic collision, // active in case of collision between two objects
//			output logic out_collision_BallWall,
//			output logic out_collision_BallHole,
//			output logic out_collision_BallBall, // critical code, generating A single pulse in a frame 
			output logic [`NUM_BALLS:0] balls_in_game, ///***IMPORTANT! - do we need to change to assign???*** or keep synchronic??
			output logic [`NUM_BALLS:0] balls_collide,
			output logic [`NUM_BALLS:0] ballwall_collide,
			output logic [1:0] collided_wall,
			//output logic signed [1:0] Balls_col_X_Speed_OUT [10:0], // ***check here what is signed and what is unsigned***
			//output logic signed [1:0] Balls_col_Y_Speed_OUT [10:0] // ***NUMBALLS - unsigned,    10:0 - signed***
			output logic [1:0][3:0] Balls_col_ID  ///***IMPORTANT! - do we need to change to assign???*** or keep synchronic??



);




logic [`NUM_BALLS:0] zeroVec;
assign zeroVec = {(`NUM_BALLS+1){1'b0}};

logic [`NUM_BALLS:0] oneVec;
assign oneVec = {(`NUM_BALLS+1){1'b1}};

//logic	[`NUM_BALLS:0] allBalls_DR_VEC,
//assign allBalls_DR_VEC = {Balls_DR_VEC,WhiteBall_DR};


// WhiteBall_DR   -->  smiley
// Table_DR      -->  brackets
// Balls_DR_VEC      -->  number/box 
// Hole_DR

//localparam zeroVec = (NUM_BALLS)'b00;
//assign collision = ( (WhiteBall_DR &&  Table_DR) || (Table_DR && Balls_DR_VEC!=2'b00) || (WhiteBall_DR &&  Balls_DR_VEC!=2'b00)
//							|| (Hole_DR && WhiteBall_DR) || (Hole_DR && Balls_DR_VEC!=2'b00) (Balls_DR_VEC!=2'b00 && ???? ) );// any collision ADD!!!

logic collision_BallWall;
logic collision_BallHole;
logic collision_BallBall;
assign collision = collision_BallWall || collision_BallHole || collision_BallBall;
assign collision_BallWall = ( (Table_DR != 2'b00) && (Balls_DR_VEC != zeroVec) ); 
assign collision_BallHole = ( (Hole_DR) && (Balls_DR_VEC != zeroVec) );
assign collision_BallBall = ( (Balls_DR_VEC != zeroVec) && ( (^Balls_DR_VEC) == 1'b0 ) ); 

//assign ballwall_collide = (collision_BallWall && wallsFlag == 1'b0) ? Balls_DR_VEC : zeroVec ;  // 1.9 tried to make wall collisions async
//assign collided_wall = (collision_BallWall && wallsFlag == 1'b0) ? Table_DR : 2'b00 ;  // 1.9 tried to make wall collisions async
//assign wallsFlag = (collision_BallWall && wallsFlag == 1'b0) ? 1'b1 : 1'b0 ;  // 1.9 tried to make wall collisions async


// add colision between number and smiley definition and code as and where needed 


logic SOF_wall_counter ;
logic SOF_ball_counter ;
logic holesFlag; // a semaphore to set the output only once per frame / regardless of the number of collisions 
logic ballsFlag;
logic wallsFlag;

logic ball_col_num ;
//logic signed [1:0] Balls_col_X_Speed [10:0];
//logic signed [1:0] Balls_col_Y_Speed [10:0];
//logic signed 	[10:0]	topLeftX, // output the top left corner
//logic signed 	[10:0]	topLeftY, // output the top left corner 





always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		//disable_Ball1 = 1'b0;
		holesFlag	<= 1'b0;
		ballsFlag <= 1'b0;
		wallsFlag <= 1'b0;
		SOF_wall_counter <= 1'b0;
		SOF_ball_counter <= 1'b0;

		//out_collision_BallWall <= 1'b0 ;
		//out_collision_BallHole <= 1'b0 ; 
		//out_collision_BallBall <= 1'b0 ; 
		balls_in_game <= oneVec ;
		balls_collide <= zeroVec ;
		ballwall_collide <= zeroVec;
		collided_wall <= 2'b00;
		Balls_col_ID <= {2{4'b0000}};
		//Balls_X_Speed_OUT <= {(`NUM_BALLS+1){11'b0}};
		//Balls_Y_Speed_OUT <= {(`NUM_BALLS+1){11'b0}};
	end 
	
	else begin 
		
		//out_collision_BallWall <= 1'b0 ; //defaults
		//out_collision_BallHole <= 1'b0 ; //defaults
		//out_collision_BallBall <= 1'b0 ;	//defaults
		//balls_collide = zeroVec ;
		ballwall_collide <= zeroVec ;
		collided_wall <= 2'b00;
		Balls_col_ID <= {2{4'b0000}};  ///***IMPORTANT! - do we need to change to assign???*** or keep synchronic??
		balls_collide <= zeroVec ;
		
		if(startOfFrame) 
			begin
			if ( SOF_ball_counter == 1'b1 )
				begin
					ballsFlag <= 1'b0;
					SOF_ball_counter <= 1'b0;
				end
			else if ( ballsFlag == 1'b1 )
				begin
					SOF_ball_counter <= 1'b1;
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
			
//		change the section below  to collision between number and smiley


		if ( collision_BallHole  && (holesFlag == 1'b0)) //***EXTRA*** - move ball hole hit reaction to movecollision block
			begin 
				holesFlag	<= 1'b1; // to enter only once 
				//out_collision_BallHole <= 1'b1; 
				balls_in_game <= (balls_in_game) & (~Balls_DR_VEC) ;
			end

		if ( collision_BallBall  && (ballsFlag == 1'b0)) 
			begin 
				balls_collide <= Balls_DR_VEC;
				ballsFlag	<= 1'b1; // to enter only once 
				//out_collision_BallBall <= 1'b1;
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
	// assign balls_collide = collision_BallBall ? Balls_DR_VEC : zeroVec ;		//***EXTRA*** : check if needed

		if ( collision_BallWall  && (wallsFlag == 1'b0)) 
			begin 
				wallsFlag <= 1'b1; // to enter only once 
				//out_collision_BallWall <= 1'b1; 
				//ballwall_collide[] <= Balls_DR_VEC;
				ballwall_collide <= Balls_DR_VEC;
				collided_wall <= Table_DR;
			end 
			
/*		//ball2ball collision with speed gathering
		if ( collision_BallBall  && (flag == 1'b0)) 
			begin 
				flag	<= 1'b1; // to enter only once 
				//out_collision_BallBall <= 1'b1;
				ball_col_num <= 1'b0;			
				for (int ballID=0; ballID < `NUM_BALLS+1 ; ballID++)
					begin
						if(Balls_DR_VEC[i] == 1'b1)
						begin
							Balls_col_X_Speed[ball_col_num] <= Balls_X_Speed[ballID] ;
							Balls_col_Y_Speed[ball_col_num] <= Balls_Y_Speed[ballID] ;
							if(ball_col_num == 1'b1)
								break;
							ball_col_num == 1'b1;
						end
					end
				balls_collide <= Balls_DR_VEC;	
			end 
*/
			
	end 
end

endmodule
