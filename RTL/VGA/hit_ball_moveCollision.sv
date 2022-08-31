// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	hit_ball_moveCollision	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					//input logic ballEnable, //***EXTRA*** - if ball was inserted to hole - change position to down screen 
					
					//***EXTRA - take charge out of move_coll -> input as speed when enter pressed***
					input	logic	chargeUp,  //charge YspeedCounter with negative speed
					input	logic	chargeDown,  //charge YspeedCounter with positive speed
					input	logic	chargeLeft,  //charge XspeedCounter with negative speed
					input	logic	chargeRight,  //charge XspeedCounter with positive speed
					input	logic	releaseBall, 	//release the white ball
					
					input logic collision,  // collision if ball hits an object
					input logic collision_with_ball,  // collision if ball hits ball
					input logic collision_with_wall,  // collision if ball hits wall
					input logic [1:0] collided_wall,
					//***coliision with hole in hitBallBM***
					//more collisions?
					input	logic	[3:0] HitEdgeCode, //for ballToBall collision

					output	logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	logic signed	[10:0]	topLeftY, // can be negative , if the object is partliy outside 
					output	logic signed 	[10:0] 	XspeedOUT,
					output	logic signed 	[10:0] 	YspeedOUT

);


// a module used to generate the  ball trajectory.  

/*
parameter int INITIAL_X = 280; // omer 22.08 :
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_Y_SPEED = 20;
parameter int MAX_Y_SPEED = 230;
const int  Y_ACCEL = -1;
*/

// omer 22.08 : fit smiley to whiteBall
parameter int BALL_ID = 0; ///***if white - 0***
//parameter logic [7:0] HITBALL_COLOR = 8'h00;

parameter int INITIAL_X = 400; 
parameter int INITIAL_Y = 220;

localparam int INITIAL_X_SPEED = 0;
localparam int INITIAL_Y_SPEED = 0;
localparam int INITIAL_Y_ACCEL = 0;
localparam int INITIAL_X_ACCEL = 0;
localparam int MIN_Y_SPEED = 2;
localparam int MIN_X_SPEED = 2;

//whiteBall local params:
localparam int MAX_Y_SHOT_SPEED = 800;
localparam int MAX_X_SHOT_SPEED = 800;
localparam int SPEED_STEP = 200;
localparam int FRICTION_STEP = 1;




const int	FIXED_POINT_MULTIPLIER	=	64;
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
//const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
//const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER;
//const int	bracketOffset =	30;
//const int   OBJECT_WIDTH_X = 32; //ball pixel width? changed from 64
//const int   OBJECT_HEIGHT_Y = 32; //ball pixel height? created

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;
int  Yaccel; //friction - needs to be opposite to movement
int  Xaccel; //friction - needs to be opposite to movement
int XShotSpeed, XShotFriction;
int YShotSpeed, YShotFriction;
 
//int X_ACCEL_DEVIDER = 128;
//int Y_ACCEL_DEVIDER = 128;



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin 
			Yspeed	<= INITIAL_Y_SPEED;
			Yaccel <= INITIAL_Y_ACCEL;
			YShotFriction <= 0;
			YShotSpeed <= 0;
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
		end 
	
	else 
		
		begin
		
			if(BALL_ID == 0 && Yspeed == 0 && Xspeed == 0 ) //relevant for WhiteBall only!!!
				begin
					// Keyboard Inputs Y - short instanced:		
					if (chargeUp && YShotSpeed < MAX_Y_SHOT_SPEED) 
						begin // button up was pushed --> going down 
							YShotSpeed <= YShotSpeed + SPEED_STEP;
							YShotFriction <= YShotFriction - FRICTION_STEP;
						end
					
					if (chargeDown && -YShotSpeed < MAX_Y_SHOT_SPEED) 
						begin // button down was pushed --> going up
							YShotSpeed <= YShotSpeed - SPEED_STEP;
							YShotFriction <= YShotFriction + FRICTION_STEP;
						end
						
					if (releaseBall)
						begin		
							Yspeed <= YShotSpeed;
							Yaccel <= YShotFriction;
							YShotSpeed <= 0;
							YShotFriction <= 0;
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
			
		if (collision_with_ball && (HitEdgeCode [2] == 1) )  // hit top border of brick  
				if (Yspeed < 0) // while moving up
					begin
						Yspeed <= -Yspeed;
						Yaccel <= -Yaccel;
					end
			
		if (collision_with_ball && (HitEdgeCode [0] == 1 ) )// || (collision && HitEdgeCode [1] == 1 ))   hit bottom border of brick  
				if (Yspeed > 0 )//  while moving down
					begin
						Yspeed <= -Yspeed;
						Yaccel <= -Yaccel;
					end

		if (collision_with_wall && (collided_wall[1] == 1'b1))  // hit top border of brick  
			begin
				Yspeed <= -Yspeed;
				Yaccel <= -Yaccel;
			end
			

			
		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) 
			
			begin 
			
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 
				
			// if ( (Yspeed > 0 && Yaccel > 0 ) || (Yspeed < 0 && Yaccel < 0) )
			//		begin
			//			Yaccel <= -Yaccel;
			//		end

				
				if ( (Yspeed > MIN_Y_SPEED && Yspeed + Yaccel > 0 ) || (Yspeed < -MIN_Y_SPEED && Yspeed + Yaccel < 0) ) //  limit the speed while going down 
					begin
						if(collision)		
							begin
								Yspeed <= Yspeed;  
							end
						
						else //no colision
							begin
								Yspeed <= Yspeed  + Yaccel ; // deAccelerate : slow the speed down every clock tick 
							end
					end
				else
					begin
						Yspeed <= 0;
						Yaccel <= 0;
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
		Xspeed	<= INITIAL_X_SPEED;
		Xaccel <= INITIAL_X_ACCEL;
		XShotFriction <= 0;
		XShotSpeed <= 0;
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
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
							XShotFriction <= XShotFriction - FRICTION_STEP;
						end
					
					if (chargeRight && (-XShotSpeed < MAX_X_SHOT_SPEED))
					// button right was pushed --> going left
						begin 
							XShotSpeed <= XShotSpeed - SPEED_STEP;	
							XShotFriction <= XShotFriction + FRICTION_STEP;
						end 
					
					if (releaseBall)
						begin		
							Xspeed <= XShotSpeed;
							Xaccel <= XShotFriction;
							XShotSpeed <= 0;
							XShotFriction <= 0;
						end
				end		
							
	
				
	// collisions with the sides 			
				if ( collision_with_ball && (HitEdgeCode [3] == 1) ) 
					if (Xspeed < 0 ) // while moving left
						begin  
								Xspeed <= -Xspeed; // positive move right 
								Xaccel <= -Xaccel;
						end
			
				if ( collision_with_ball && (HitEdgeCode [1] == 1) ) 
					 // hit right border of brick  
					if (Xspeed > 0 ) //  while moving right
						begin
								Xspeed <= -Xspeed;  // negative move left  
								Xaccel <= -Xaccel;
						end	
						
				if ( collision_with_wall && (collided_wall[0] == 1'b1) )  // hit top border of brick  
					begin
						Xspeed <= -Xspeed;
						Xaccel <= -Xaccel;
					end
		   
			
		if (startOfFrame == 1'b1) 
			begin 
		
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 

			//	if ( (Xspeed > 0 && Xaccel > 0 ) || (Xspeed < 0 && Xaccel < 0) )
			//		begin
			//			Xaccel <= -Xaccel;
			//		end
				
				if ( (Xspeed > MIN_X_SPEED && Xspeed + Xaccel > 0 ) || (Xspeed < -MIN_X_SPEED && Xspeed + Xaccel < 0) ) //  limit the speed while going left or right 
					begin
						if(collision)		
							begin
								Xspeed <= Xspeed;  
							end
						
						else //no colision
							begin
								Xspeed <= Xspeed  + Xaccel ; // deAccelerate : slow the speed down every clock tick 
							end
					end
				else
					begin
						Xspeed <= 0;
						Xaccel <=0;
					end
			end;
					
	end
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;
assign 	XspeedOUT = Xspeed;
assign 	YspeedOUT = Yspeed;    
    


endmodule
