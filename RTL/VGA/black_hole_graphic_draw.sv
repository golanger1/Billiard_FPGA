// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018
// updaed Eyal Lev Feb 2021


module	black_hole_graphic_draw	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					/*
//					input	logic	chargeUp,  //charge YspeedCounter with negative speed
//					input	logic	chargeDown,  //charge YspeedCounter with positive speed
//					input	logic	chargeLeft,  //charge XspeedCounter with negative speed
//					input	logic	chargeRight,  //charge XspeedCounter with positive speed
//					input logic collision,  //collision if ball hits an object
//					input	logic	[3:0] HitEdgeCode, */

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
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
parameter int INITIAL_TOP_LEFT_X = 0; 
parameter int INITIAL_TOP_LEFT_Y = 0;

// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions
const int	FIXED_POINT_MULTIPLIER	=	64;

/*
//parameter int INITIAL_X_SPEED = 0;
//parameter int INITIAL_Y_SPEED = 0;
//parameter int INITIAL_Y_ACCEL = 0;
//parameter int INITIAL_X_ACCEL = 0;
//parameter int MIN_Y_SPEED = 2; //is this necessary? was MAX_.. = 230


//const int	x_FRAME_SIZE	=	639 * FIXED_POINT_MULTIPLIER; // note it must be 2^n 
//const int	y_FRAME_SIZE	=	479 * FIXED_POINT_MULTIPLIER; */
const int	bracketOffset =	35;
const int   OBJECT_WIDTH_X = 40; //ball pixel width? changed from 64
const int   OBJECT_HEIGHT_Y = 40; //ball pixel height? created


int topLeftX_FixedPoint; 
int topLeftY_FixedPoint;
/*
int Xspeed;
int Yspeed;
int  Yaccel; //friction - needs to be opposite to movement
int  Xaccel; //friction - needs to be opposite to movement
int XShotSpeed;
int YShotSpeed;
*/



//////////--------------------------------------------------------------------------------------------------------------=
//  calculation 0f Y Axis speed using gravity or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin 
		//Yspeed	<= INITIAL_Y_SPEED;
		//Yaccel <= INITIAL_Y_ACCEL;
		topLeftY_FixedPoint	<= INITIAL_TOP_LEFT_Y * FIXED_POINT_MULTIPLIER;
	end 
	/*
	else begin
	// colision Calcultaion 
			
		//hit bit map has one bit per edge:  Left-Top-Right-Bottom	 

	
		if ((collision && HitEdgeCode [2] == 1 ))  // hit top border of brick  
				if (Yspeed < 0) // while moving up
						Yspeed <= -Yspeed ;
						Yaccel <= -Yaccel;
			
		if ((collision && HitEdgeCode [0] == 1 ))// || (collision && HitEdgeCode [1] == 1 ))   hit bottom border of brick  
				if (Yspeed > 0 )//  while moving down
						Yspeed <= -Yspeed ; 
						Yaccel <= -Yaccel;


			
		// perform  position and speed integral only 30 times per second 
		
		if (startOfFrame == 1'b1) begin 
				
				topLeftY_FixedPoint  <= topLeftY_FixedPoint + Yspeed; // position interpolation 

				
				if (Yspeed > MIN_Y_SPEED) //  limit the speed while going down 
					begin
						Yaccel <= -1;
						Yspeed <= Yspeed  + Yaccel ; // deAccelerate : slow the speed down every clock tick 
					end

				else if (Yspeed < -MIN_Y_SPEED) //  limit the speed while going down 
					begin
						Yaccel <= 1;
						Yspeed <= Yspeed  + Yaccel ; // deAccelerate : slow the speed down every clock tick 
					end
				
				else
					Yspeed <= 0;
								
				if (chargeUp) begin // button was pushed to go upwards 
						if (Yspeed > 0 ) // while moving down
								Yspeed <= -Yspeed  ;  // change speed to go up 
				end ;
				
				


		end
	end
	*/
end 

//////////--------------------------------------------------------------------------------------------------------------=
//  calculation of X Axis speed using and position calculate regarding X_direction key or colision

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin
		//Xspeed	<= INITIAL_X_SPEED;
		topLeftX_FixedPoint	<= INITIAL_TOP_LEFT_X * FIXED_POINT_MULTIPLIER;
	end
	/*
	else begin
	
				
	//  an edge input is tested here as it is a very short instance   
	if (releaseBall)  
	
				Xspeed <= -Xspeed; 
				
	// collisions with the sides 			
				if (collision && HitEdgeCode [3] == 1) begin  
					if (Xspeed < 0 ) // while moving left
							Xspeed <= -Xspeed; // positive move right 
				end
			
				if (collision && HitEdgeCode [1] == 1 ) begin  // hit right border of brick  
					if (Xspeed > 0 ) //  while moving right
							Xspeed <= -Xspeed;  // negative move left    
				end	
		   
			
		if (startOfFrame == 1'b1 )//&& Yspeed != 0) 
	
				        //topLeftX_FixedPoint  <= topLeftX_FixedPoint + Xspeed;
						  
			
					
	end
	*/
end

//get a better (64 times) resolution using integer   
assign 	topLeftX = topLeftX_FixedPoint / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = topLeftY_FixedPoint / FIXED_POINT_MULTIPLIER ;    


endmodule
