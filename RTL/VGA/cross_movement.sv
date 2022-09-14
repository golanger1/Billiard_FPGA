// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	cross_movement	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					
					//***EXTRA - take charge out of move_coll -> input as speed when enter pressed***
					input	logic	angleUp,  //was chargeUp (2)
					input	logic	angleDown,  //was chargeDown (8)
					input	logic	angleLeft,  //was chargeLeft (6)
					input	logic	angleRight,  //was chargeRight (4)
					input	logic	speedUp,  //was needs to be +
					input	logic	speedDown,  //was needs to be -
					input	logic	releaseBall, 	// forward speed to WhiteBall
					
					input logic WhiteBall_inGame,
					input logic signed [10:0] WhiteBall_topLeftX,  
					input logic signed [10:0] WhiteBall_topLeftY,
					input logic signed [10:0] WhiteBall_Xspeed_in,  
					input logic signed [10:0] WhiteBall_Yspeed_in,


					output	logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	logic signed	[10:0]	topLeftY, // can be negative , if the object is partliy outside 
					output 	logic enableCross,
					output 	logic chargeWhiteBall,
					output	logic signed 	[10:0] 	WhiteBall_Xspeed_OUT,
					output	logic signed 	[10:0] 	WhiteBall_Yspeed_OUT,
					
					
					output logic signed [31:0] Sin_Prod_abs,
					output logic signed [31:0] Cos_Prod_abs,
					output logic signed [31:0] Sin_Prod_Fixed,
					output logic signed [31:0] Cos_Prod_Fixed,
					output logic signed [31:0] WhiteBall_centerX_int, 
					output logic signed [31:0] WhiteBall_centerY_int,
					output logic signed [31:0] Cross_topLeftX_int,
					output logic signed [31:0] Cross_topLeftY_int,
					output logic signed [31:0] XShotSpeed_int,
					output logic signed [31:0] YShotSpeed_int,
					output logic signed [31:0] WhiteBall_Xspeed_OUT_int,
					output logic signed [31:0] WhiteBall_Yspeed_OUT_int,
					output logic signed [31:0] Speed_strength_int
					
					//// may be relevant:
					
					//input logic collision,  // collision if ball hits an object
					//input logic collision_with_ball,  // collision if ball hits ball
					//input logic collision_with_wall,  // collision if ball hits wall
					//input logic [1:0] collided_wall,
					//***coliision with hole in hitBallBM***
					//more collisions?
					//input	logic	[3:0] HitEdgeCode, //for ballToBall collision
);

//parameter int INITIAL_X = 400; 
//parameter int INITIAL_Y = 220;

localparam int INITIAL_X_SPEED = 0;
localparam int INITIAL_Y_SPEED = 0;
localparam int INITIAL_Y_ACCEL = 0;
localparam int INITIAL_X_ACCEL = 0;
localparam int MIN_Y_SPEED = 8; // exists also in speed calc - change accordingly
localparam int MIN_X_SPEED = 8; // exists also in speed calc - change accordingly

//local params:
//localparam int MAX_Y_SHOT_SPEED = 512;
//localparam int MAX_X_SHOT_SPEED = 512;
localparam int INITIAL_SPEED_STRENGTH = 0;
localparam int MAX_SPEED_STRENGTH = 512;
localparam int SPEED_STRENGTH_STEP = 8;
localparam int SPEED_STRENGTH_DIV_FOR_CROSS = 8;



//cross params:
localparam int WhiteBall_Radius = 16;
localparam int Cross_Distance_From_WhiteBall = 64;
localparam int Cross_Size_Radius = 4;

//angle params:
localparam ANGLE_STEP = 8'd1; 
localparam ANGLE_RIGHT = 8'd0; 
localparam ANGLE_DOWN = 8'd64; 
localparam ANGLE_LEFT = 8'd128; 
localparam ANGLE_UP = 8'd192;
localparam INITIAL_ANGLE = ANGLE_RIGHT;

const int	FIXED_POINT_MULTIPLIER	=	64;
const int	FIXED_SPEED_MULTIPLIER	=	64;
const int	FIXED_ANGLE_MULTIPLIER	=	256;

const int	FRICTION_INTENSITY	=	64;


// **GENERAL** logics
//logic enableCross ; //turned to output

// **WHITE BALL** logics
logic signed [31:0] WhiteBall_topLeftX_int, WhiteBall_topLeftY_int;
////logic signed [31:0] WhiteBall_centerX_int, WhiteBall_centerY_int; //turned to outs

// **ANGLE AND SIN** logics
logic [7:0] Angle_8bit;
logic [7:0] Angle_Sin, Angle_Cos; 
logic [7:0] SinProd8_8tmpbit, CosProd8_8tmpbit; 
logic signed [15:0] SinProd16_Fixed, CosProd16_Fixed;
////logic signed [31:0] Sin_Prod_abs, Cos_Prod_abs; //turned to outs
////logic signed [31:0] Sin_Prod_Fixed, Cos_Prod_Fixed; //turned to outs


//int SinTimesRadius, CosTimesRadius;
//int Xspeed, Yspeed;  // local parameters 

// **STRENGTH** logics
////logic signed [31:0] Speed_strength_int; //turned to outs
////logic signed [31:0] XShotSpeed_int, YShotSpeed_int; //turned to outs
////logic signed [31:0] WhiteBall_Xspeed_OUT_int, WhiteBall_Yspeed_OUT_int; //turned to outs


// **CROSS LOCATION** logics
////logic signed [31:0] Cross_topLeftX_int, Cross_topLeftY_int; //turned to outs


// assignments:
assign enableCross = (WhiteBall_Xspeed_in == 0 && WhiteBall_Yspeed_in == 0 && WhiteBall_inGame) ? 1 : 0 ; // and white ball in game
assign WhiteBall_topLeftX_int = int'(WhiteBall_topLeftX);
assign WhiteBall_topLeftY_int = int'(WhiteBall_topLeftY);
assign WhiteBall_centerX_int = WhiteBall_topLeftX_int + WhiteBall_Radius;
assign WhiteBall_centerY_int = WhiteBall_topLeftY_int + WhiteBall_Radius;
assign Angle_Sin = Angle_8bit;
assign Angle_Cos = ( Angle_8bit + 8'd64 ) ;
assign SinProd8_8tmpbit = SinProd16_Fixed[7:0];
assign CosProd8_8tmpbit = CosProd16_Fixed[7:0];
assign Sin_Prod_abs = int'(SinProd8_8tmpbit);
assign Cos_Prod_abs = int'(CosProd8_8tmpbit);
assign Sin_Prod_Fixed = (Angle_Sin < 8'd129) ? Sin_Prod_abs : (Sin_Prod_abs-255) ;
assign Cos_Prod_Fixed = (Angle_Cos < 8'd129) ? Cos_Prod_abs : (Cos_Prod_abs-255) ;
assign XShotSpeed_int = (Cos_Prod_Fixed*Speed_strength_int) / FIXED_ANGLE_MULTIPLIER;
assign YShotSpeed_int = (Sin_Prod_Fixed*Speed_strength_int) / FIXED_ANGLE_MULTIPLIER;

// outs
assign 	topLeftX = Cross_topLeftX_int[10:0];
assign 	topLeftY = Cross_topLeftY_int[10:0];
assign   WhiteBall_Xspeed_OUT = WhiteBall_Xspeed_OUT_int[10:0];
assign   WhiteBall_Yspeed_OUT = WhiteBall_Yspeed_OUT_int[10:0];   

// sine and cosine components

sintable_cross sin_cross(  .clk(clk),
									.resetN(resetN),
									.ADDR(Angle_Sin),			//input	logic [COUNT_SIZE-1:0]	ADDR,
									.Q(SinProd16_Fixed)		//output	logic [15:0]	Q // table function output 
								);
								
sintable_cross cos_cross(  .clk(clk),
									.resetN(resetN),
									.ADDR(Angle_Cos),			//input	logic [COUNT_SIZE-1:0]	ADDR,
									.Q(CosProd16_Fixed)		//output	logic [15:0]	Q // table function output 
								);

//just for check:
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin
			Angle_8bit <= INITIAL_ANGLE;
			Speed_strength_int <= INITIAL_SPEED_STRENGTH;
			
//			Cross_topLeftX_int <= WhiteBall_centerX_int - Cross_Size_Radius + ( (Cos_Prod_Fixed*Cross_Distance_From_WhiteBall) / FIXED_ANGLE_MULTIPLIER ) ;
//			Cross_topLeftY_int <= WhiteBall_centerY_int - Cross_Size_Radius + ( (Sin_Prod_Fixed*Cross_Distance_From_WhiteBall) / FIXED_ANGLE_MULTIPLIER ) ;
			
			Cross_topLeftX_int <= WhiteBall_centerX_int - Cross_Size_Radius + ( (Cos_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
			Cross_topLeftY_int <= WhiteBall_centerY_int - Cross_Size_Radius + ( (Sin_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
			
			//XShotSpeed_int <= (Cos_Prod_Fixed*INITIAL_SPEED_STRENGTH) / FIXED_ANGLE_MULTIPLIER;
			//YShotSpeed_int <= (Sin_Prod_Fixed*INITIAL_SPEED_STRENGTH) / FIXED_ANGLE_MULTIPLIER;

			chargeWhiteBall <= 1'b0;
		end
	else
		begin
		
			chargeWhiteBall <= 1'b0;
			//release and WhiteBall Speed Charging:
			if (releaseBall == 1'b1  && Speed_strength_int > 0 )
			begin
				chargeWhiteBall <= 1'b1;
				WhiteBall_Xspeed_OUT_int <= XShotSpeed_int ;
				WhiteBall_Yspeed_OUT_int <= YShotSpeed_int ;
				Angle_8bit <= INITIAL_ANGLE;
				Speed_strength_int <= INITIAL_SPEED_STRENGTH;
			end
//			else
//			begin
//				WhiteBall_Xspeed_OUT_int <= 0;
//				WhiteBall_Yspeed_OUT_int <= 0;			
//			end
			
			if (startOfFrame)
			begin
			
				//main angle (Angle_8bit) assignments:
				if (angleUp)
				begin
					if (Angle_8bit < ANGLE_UP && Angle_8bit >= ANGLE_DOWN ) //including left angle
						Angle_8bit <= Angle_8bit + ANGLE_STEP ;
					else if (Angle_8bit != ANGLE_UP )
						Angle_8bit <= Angle_8bit - ANGLE_STEP ;
				end
				
				else if (angleDown)
				begin
					if (Angle_8bit > ANGLE_DOWN && Angle_8bit <= ANGLE_UP ) //including left angle
						Angle_8bit <= Angle_8bit - ANGLE_STEP ;
					else if (Angle_8bit != ANGLE_DOWN )
						Angle_8bit <= Angle_8bit + ANGLE_STEP ;
				end	
				
				else if (angleLeft)
				begin
					if (Angle_8bit < ANGLE_LEFT && Angle_8bit >= ANGLE_RIGHT ) //including left angle
						Angle_8bit <= Angle_8bit + ANGLE_STEP ;
					else if (Angle_8bit != ANGLE_LEFT )
						Angle_8bit <= Angle_8bit - ANGLE_STEP ;
				end
				
				else if (angleRight)
				begin
					if (Angle_8bit > ANGLE_RIGHT && Angle_8bit <= ANGLE_LEFT ) //including left angle
						Angle_8bit <= Angle_8bit - ANGLE_STEP ;
					else if (Angle_8bit != ANGLE_RIGHT )
						Angle_8bit <= Angle_8bit + ANGLE_STEP ;
				end
				
				
				// speed strength assignments:
				if ( speedDown && Speed_strength_int >= SPEED_STRENGTH_STEP )
					Speed_strength_int <= Speed_strength_int - SPEED_STRENGTH_STEP;
					
				else if ( speedUp && Speed_strength_int <= MAX_SPEED_STRENGTH - SPEED_STRENGTH_STEP )
					Speed_strength_int <= Speed_strength_int + SPEED_STRENGTH_STEP;

				
				//cross location assignment
				Cross_topLeftX_int <= WhiteBall_centerX_int - Cross_Size_Radius + ( (Cos_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
				Cross_topLeftY_int <= WhiteBall_centerY_int - Cross_Size_Radius + ( (Sin_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
			end
		
		end

end
 


//assign SinTimesRadius?? = 
/// ***stopped here - 120922***




/****START COMMENT

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin 
			//Yspeed	<= INITIAL_Y_SPEED; //changed 1.9
			//Yaccel <= INITIAL_Y_ACCEL; //changed 1.9
			//YShotFriction <= 0;	//do we need???? //changed 1.9
			Angle_8bit <= INITIAL_ANGLE; 
			topLeftY_FixedPoint	<= INITIAL_ANGLE * ;
			Yspeed_Fixed	<= INITIAL_Y_SPEED * FIXED_SPEED_MULTIPLIER; //changed 1.9

		end 
	
	else 
		
		begin
		
			if(BALL_ID == 0 && Yspeed == 0 && Xspeed == 0 ) //relevant for WhiteBall only!!!
				begin
					// Keyboard Inputs Y - short instanced:		
					if (chargeUp && YShotSpeed < MAX_Y_SHOT_SPEED) 
						begin // button up was pushed --> going down 
							YShotSpeed <= YShotSpeed + SPEED_STEP;
							//YShotFriction <= YShotFriction - FRICTION_STEP; //changed 1.9
						end
					
					if (chargeDown && -YShotSpeed < MAX_Y_SHOT_SPEED) 
						begin // button down was pushed --> going up
							YShotSpeed <= YShotSpeed - SPEED_STEP;
							//YShotFriction <= YShotFriction + FRICTION_STEP; //changed 1.9
						end
						
					if (releaseBall)
						begin		
							Yspeed_Fixed <= YShotSpeed * FIXED_SPEED_MULTIPLIER;
							//Yaccel <= YShotFriction;
							YShotSpeed <= 0;
							//YShotFriction <= 0;
						end
				end
		//collisions:
		//hit bit map has one bit per edge:  Left-Top-Right-Bottom	 
		
	//if ball-hole
	//else if:
			// if (WhiteB || HitB)
			// if (Table)
				
//		if (BallHole_collision) //change location to down screen
//			begin
//				
//			end
		
		if ( collision_with_ball )
			begin
				Yspeed_Fixed <= (Yspeed_in * FIXED_SPEED_MULTIPLIER); //boosted in speedCalc	
			end


		if (collision_with_wall && (collided_wall[1] == 1'b1))  // hit top border of brick  
			if( Yspeed_Fixed < 0 )
				begin
					Yspeed_Fixed <= -Yspeed_Fixed + MIN_Y_SPEED*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
					//Yaccel <= -Yaccel;  //changed 1.9
				end
			else if( Yspeed_Fixed > 0 )
				begin
					Yspeed_Fixed <= -Yspeed_Fixed - MIN_Y_SPEED*FIXED_SPEED_MULTIPLIER;  //changed 1.9
					//Yaccel <= -Yaccel;  //changed 1.9
				end
			//else (yspeed==0) ? 

			
		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) 
			
			begin 
			
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation // changed 1.9 - is it Yspeed or Yspeed_Fixed???
				
			// if ( (Yspeed > 0 && Yaccel > 0 ) || (Yspeed < 0 && Yaccel < 0) )
			//		begin
			//			Yaccel <= -Yaccel;
			//		end

				
				if ( (Yspeed_Fixed > MIN_Y_SPEED * FIXED_SPEED_MULTIPLIER && Yspeed_Fixed - Y_FRICTION > 0 ) || (Yspeed_Fixed < -MIN_Y_SPEED*FIXED_SPEED_MULTIPLIER && Yspeed_Fixed - Y_FRICTION < 0) ) //  limit the speed while going down   //changed 1.9
					begin
						Yspeed_Fixed <= Yspeed_Fixed - Y_FRICTION ; // deAccelerate : slow the speed down every clock tick   //changed 1.9
					end  
				else if ( ( (Xspeed_Fixed > MIN_X_SPEED * FIXED_SPEED_MULTIPLIER) || (Xspeed_Fixed < -MIN_X_SPEED*FIXED_SPEED_MULTIPLIER) ) && ( Yspeed_Fixed != 0 ) )
					begin
						Yspeed_Fixed <= (( Yspeed_Fixed > 0 ) ? 1 : -1 )*(MIN_Y_SPEED/4)*FIXED_SPEED_MULTIPLIER;				
					end
				else
					begin
						Yspeed_Fixed <= 0;
						//Yaccel <= 0; //changed 1.9
					end
								
			end;
				
				


		end
	end 



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		//Xspeed	<= INITIAL_X_SPEED;
		//Xaccel <= INITIAL_X_ACCEL;
		//XShotFriction <= 0;
		XShotSpeed <= 0;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		Xspeed_Fixed	<= INITIAL_X_SPEED * FIXED_SPEED_MULTIPLIER; //changed 1.9

	end
	else 
		begin
			
			if(BALL_ID ==0 && Yspeed == 0 && Xspeed == 0 ) //relevant for WhiteBall only!!!
				begin
					// Keyboard Inputs X - short instanced:
					if (chargeLeft && (XShotSpeed < MAX_X_SHOT_SPEED) ) 
					// button left was pushed --> going right
						begin 
							XShotSpeed <= XShotSpeed + SPEED_STEP;
							//XShotFriction <= XShotFriction - FRICTION_STEP;
						end
					
					if (chargeRight && (-XShotSpeed < MAX_X_SHOT_SPEED))
					// button right was pushed --> going left
						begin 
							XShotSpeed <= XShotSpeed - SPEED_STEP;	
							//XShotFriction <= XShotFriction + FRICTION_STEP;
						end 
					
					if (releaseBall)
						begin		
							Xspeed_Fixed <= XShotSpeed * FIXED_SPEED_MULTIPLIER;
							//Xaccel <= XShotFriction;
							XShotSpeed <= 0;
							//XShotFriction <= 0;
						end
				end		
							
	
		// collisions with the sides 	
		
			if ( collision_with_ball )
				begin
					Xspeed_Fixed <= (Xspeed_in * FIXED_SPEED_MULTIPLIER); // ?Xspeed_in for better collision speed	
				end

						
			if ( collision_with_wall && (collided_wall[0] == 1'b1) )  // hit top border of brick  
				if( Xspeed_Fixed < 0 )
					begin
						Xspeed_Fixed <= -Xspeed_Fixed + MIN_X_SPEED*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
						//Xaccel <= -Xaccel;
					end
				else if( Xspeed_Fixed > 0 )
					begin
						Xspeed_Fixed <= -Xspeed_Fixed - MIN_X_SPEED*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
						//Xaccel <= -Xaccel;
					end
					
			
		if (startOfFrame == 1'b1) 
			begin 
		
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 

			//	if ( (Xspeed > 0 && Xaccel > 0 ) || (Xspeed < 0 && Xaccel < 0) )
			//		begin
			//			Xaccel <= -Xaccel;
			//		end
				if ( (Xspeed_Fixed > MIN_X_SPEED*FIXED_SPEED_MULTIPLIER && (Xspeed_Fixed - X_FRICTION > 0 ) ) || (Xspeed_Fixed < -MIN_X_SPEED*FIXED_SPEED_MULTIPLIER && (Xspeed_Fixed - X_FRICTION < 0) ) ) //  limit the speed while going left or right 
					begin
						Xspeed_Fixed <= Xspeed_Fixed - X_FRICTION ; // deAccelerate : slow the speed down every clock tick 
					end
				else if ( ( (Yspeed_Fixed > MIN_Y_SPEED * FIXED_SPEED_MULTIPLIER) || (Yspeed_Fixed < -MIN_Y_SPEED*FIXED_SPEED_MULTIPLIER) ) && ( Xspeed_Fixed != 0 ) )
					begin
						Xspeed_Fixed <= (( Xspeed_Fixed > 0 ) ? 1 : -1 )*(MIN_X_SPEED/4)*FIXED_SPEED_MULTIPLIER;				
					end
				else
					begin
						Xspeed_Fixed <= 0;
					end
			end;			
	end
end

//get a better (64 times) resolution using integer   
//assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
//assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;



assign 	Xspeed = Xspeed_Fixed / FIXED_SPEED_MULTIPLIER;
assign 	Yspeed = Yspeed_Fixed / FIXED_SPEED_MULTIPLIER;

assign 	XspeedOUT = Xspeed;  //changed 1.9
assign 	YspeedOUT = Yspeed;  //changed 1.9  

STOP COMMENT*/




endmodule
