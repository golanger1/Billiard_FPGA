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
					input logic signed [10:0] Xspeed_in,  // new speed from the speed calculations unit
					input logic signed [10:0] Yspeed_in,

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
localparam int MIN_Y_SPEED = 8;
localparam int MIN_X_SPEED = 8;

//whiteBall local params:
localparam int MAX_Y_SHOT_SPEED = 512;
localparam int MAX_X_SHOT_SPEED = 512;
localparam int SPEED_STEP = 64;





const int	FIXED_POINT_MULTIPLIER	=	64;
const int	FIXED_SPEED_MULTIPLIER	=	64;
const int	FRICTION_INTENSITY	=	64;


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
int Xspeed_Fixed, Yspeed_Fixed;
int XShotSpeed, XShotFriction;
int YShotSpeed, YShotFriction;
 
//int Friction_dev;

int X_FRICTION;
assign 	X_FRICTION = Xspeed_Fixed / FRICTION_INTENSITY;     //***changed 1.9
//int  Xaccel; //friction - needs to be opposite to movement //changed 1.9
int Y_FRICTION;
assign 	Y_FRICTION = Yspeed_Fixed / FRICTION_INTENSITY;  //***changed 1.9  
//int  Yaccel; //friction - needs to be opposite to movement //changed 1.9

//always_comb //changed 1.9 try change speed - not good
//	begin
//		if(Xspeed>64 && Yspeed>64)
//		begin
//			Friction_dev = 64;
//		end
//		else if(Xspeed>32 && Yspeed>32)
//		begin
//			Friction_dev = 32;
//		end
//		else if(Xspeed>16 && Yspeed>16)
//		begin
//			Friction_dev = 16;
//		end
//		else if(Xspeed>8 && Yspeed>8)
//		begin
//			Friction_dev = 8;
//		end
//		else if(Xspeed>4 && Yspeed>4)
//		begin
//			Friction_dev = 4;
//		end
//		else if(Xspeed>2 && Yspeed>2)
//		begin
//			Friction_dev = 2;
//		end
//		else
//		begin
//			Friction_dev = 1;
//		end
//		
//	end


//int X_ACCEL_DEVIDER = 128;
//int Y_ACCEL_DEVIDER = 128;



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin 
			//Yspeed	<= INITIAL_Y_SPEED; //changed 1.9
			//Yaccel <= INITIAL_Y_ACCEL; //changed 1.9
			//YShotFriction <= 0;	//do we need???? //changed 1.9
			YShotSpeed <= 0;		
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
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
				Yspeed_Fixed <= (Yspeed_in * FIXED_SPEED_MULTIPLIER) + Yspeed_in; // Yspeed_in for better collision speed
			end
	/***
		using hitEdgeCode:
		
		if (collision_with_ball && (HitEdgeCode [2] == 1) )  // hit top border of brick  
				if (Yspeed_Fixed < 0) // while moving up
					begin
						Yspeed_Fixed <= -Yspeed_Fixed;
						//Yaccel <= -Yaccel;  //changed 1.9
					end
				else if (Yspeed_Fixed == 0)
					begin
						Yspeed_Fixed <= 128 * FIXED_SPEED_MULTIPLIER;
						//Yaccel <= -1; //changed 1.9
					end
			
		if (collision_with_ball && (HitEdgeCode [0] == 1 ) )// || (collision && HitEdgeCode [1] == 1 ))   hit bottom border of brick  
				if (Yspeed_Fixed > 0 )//  while moving down
					begin
						Yspeed_Fixed <= -Yspeed_Fixed;
						//Yaccel <= -Yaccel;  //changed 1.9
					end
				else if (Yspeed_Fixed == 0)
					begin
						Yspeed_Fixed <= -128 * FIXED_SPEED_MULTIPLIER;
						//Yaccel <= 1;  //changed 1.9
					end
	***/

		if (collision_with_wall && (collided_wall[1] == 1'b1))  // hit top border of brick  
			if( Yspeed_Fixed < 0 )
				begin
					Yspeed_Fixed <= -Yspeed_Fixed + 5*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
					//Yaccel <= -Yaccel;  //changed 1.9
				end
			else if( Yspeed_Fixed > 0 )
				begin
					Yspeed_Fixed <= -Yspeed_Fixed - 5*FIXED_SPEED_MULTIPLIER;  //changed 1.9
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
					Xspeed_Fixed <= (Xspeed_in * FIXED_SPEED_MULTIPLIER) + Xspeed_in; // +Xspeed_in for better collision speeds;
				end
	/***
		using hitEdgeCode:
				
				if ( collision_with_ball && (HitEdgeCode [3] == 1) ) 
					if (Xspeed_Fixed < 0 ) // while moving left
						begin  
								Xspeed_Fixed <= -Xspeed_Fixed; // positive move right 
								//Xaccel <= -Xaccel;
						end
					else if (Xspeed_Fixed == 0)
						begin
							Xspeed_Fixed <= 128 * FIXED_SPEED_MULTIPLIER;
							//Xaccel <= -1;
						end	
				
				
				if ( collision_with_ball && (HitEdgeCode [1] == 1) ) 
					 // hit right border of brick  
					if (Xspeed_Fixed > 0 ) //  while moving right
						begin
								Xspeed_Fixed <= -Xspeed_Fixed; // positive move right 
								//Xaccel <= -Xaccel;
						end
					else if (Xspeed_Fixed == 0)
						begin
							Xspeed_Fixed <= -128 * FIXED_SPEED_MULTIPLIER;
							//Xaccel <= 1;
						end	
	***/
						
			if ( collision_with_wall && (collided_wall[0] == 1'b1) )  // hit top border of brick  
				if( Xspeed_Fixed < 0 )
					begin
						Xspeed_Fixed <= -Xspeed_Fixed + 5*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
						//Xaccel <= -Xaccel;
					end
				else if( Xspeed_Fixed > 0 )
					begin
						Xspeed_Fixed <= -Xspeed_Fixed - 5*FIXED_SPEED_MULTIPLIER; //do we need to add speed?
						//Xaccel <= -Xaccel;
					end
					
			
		if (startOfFrame == 1'b1) 
			begin 
		
				topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed; // position interpolation 

			//	if ( (Xspeed > 0 && Xaccel > 0 ) || (Xspeed < 0 && Xaccel < 0) )
			//		begin
			//			Xaccel <= -Xaccel;
			//		end
				
				if ( (Xspeed_Fixed > MIN_X_SPEED*FIXED_SPEED_MULTIPLIER && Xspeed_Fixed - X_FRICTION > 0 ) || (Xspeed_Fixed < -MIN_X_SPEED*FIXED_SPEED_MULTIPLIER && Xspeed_Fixed - X_FRICTION < 0) ) //  limit the speed while going left or right 
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
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;

assign 	Xspeed = Xspeed_Fixed / FIXED_SPEED_MULTIPLIER;
assign 	Yspeed = Yspeed_Fixed / FIXED_SPEED_MULTIPLIER;

assign 	XspeedOUT = Xspeed;  //changed 1.9
assign 	YspeedOUT = Yspeed;  //changed 1.9  



endmodule
