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
					
					input 	logic chargeWhiteBall,
					input		logic signed 	[10:0] 	WhiteBall_Xspeed_Charge,
					input		logic signed 	[10:0] 	WhiteBall_Yspeed_Charge,
					
					input logic collision,  // collision if ball hits an object
					input logic collision_with_ball,  // collision if ball hits ball
					input logic collision_with_wall,  // collision if ball hits wall
					input logic [1:0] collided_wall,
//					EDIT 14.09.22 
					//input	logic	[3:0] HitEdgeCode, //for ballToBall collision
					input logic signed [10:0] Xspeed_in,  // new speed from the speed calculations unit
					input logic signed [10:0] Yspeed_in,

					output	logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	logic signed	[10:0]	topLeftY, // can be negative , if the object is partliy outside 
					output	logic signed 	[10:0] 	XspeedOUT,
					output	logic signed 	[10:0] 	YspeedOUT

);


// a module used to generate the  ball trajectory.  



parameter int BALL_ID = 0; ///***if white - 0***

parameter int INITIAL_X = 400; 
parameter int INITIAL_Y = 220;

localparam int INITIAL_X_SPEED = 0;
localparam int INITIAL_Y_SPEED = 0;
localparam int INITIAL_Y_ACCEL = 0;
localparam int INITIAL_X_ACCEL = 0;
localparam int MIN_Y_SPEED = 8; // exists also in speed calc - change accordingly
localparam int MIN_X_SPEED = 8; // exists also in speed calc - change accordingly

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

int Xspeed, topLeftX_FixedPoint; // local parameters 
int Yspeed, topLeftY_FixedPoint;
int Xspeed_Fixed, Yspeed_Fixed;

//EDIT 14.09.22 

int X_FRICTION;
assign 	X_FRICTION = Xspeed_Fixed / FRICTION_INTENSITY;     //***changed 1.9
int Y_FRICTION;
assign 	Y_FRICTION = Yspeed_Fixed / FRICTION_INTENSITY;  //***changed 1.9  



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin 
			topLeftY_FixedPoint	<= INITIAL_Y * FIXED_POINT_MULTIPLIER;
			Yspeed_Fixed	<= INITIAL_Y_SPEED * FIXED_SPEED_MULTIPLIER; //changed 1.9
		end 
	
	else 
		
		begin
			
		if ( BALL_ID == 0 && chargeWhiteBall == 1'b1 )
			begin
				Yspeed_Fixed <= (WhiteBall_Yspeed_Charge * FIXED_SPEED_MULTIPLIER); //boosted in speedCalc	
			end
		
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

			
		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) 
			
			begin 
			
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation // changed 1.9 - is it Yspeed or Yspeed_Fixed???
				
				
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
		topLeftX_FixedPoint	<= INITIAL_X * FIXED_POINT_MULTIPLIER;
		Xspeed_Fixed	<= INITIAL_X_SPEED * FIXED_SPEED_MULTIPLIER; //changed 1.9
	end
	else 
		begin
			
		// whiteBall Charge: 	

			if ( BALL_ID == 0 && chargeWhiteBall == 1'b1 )
				begin
					Xspeed_Fixed <= (WhiteBall_Xspeed_Charge * FIXED_SPEED_MULTIPLIER); 	
				end
	
		// collisions with balls: 	
		
			if ( collision_with_ball )
				begin
					Xspeed_Fixed <= (Xspeed_in * FIXED_SPEED_MULTIPLIER); // ?Xspeed_in for better collision speed	
				end
				
		
		// collisions with walls: 	

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
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;

assign 	Xspeed = Xspeed_Fixed / FIXED_SPEED_MULTIPLIER;
assign 	Yspeed = Yspeed_Fixed / FIXED_SPEED_MULTIPLIER;

assign 	XspeedOUT = Xspeed;  //changed 1.9
assign 	YspeedOUT = Yspeed;  //changed 1.9  



endmodule
