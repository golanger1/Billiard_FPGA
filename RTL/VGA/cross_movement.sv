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
					output	logic signed 	[10:0] 	WhiteBall_Yspeed_OUT

);



localparam int INITIAL_X_SPEED = 0;
localparam int INITIAL_Y_SPEED = 0;
localparam int INITIAL_Y_ACCEL = 0;
localparam int INITIAL_X_ACCEL = 0;
localparam int MIN_Y_SPEED = 8; // exists also in speed calc - change accordingly
localparam int MIN_X_SPEED = 8; // exists also in speed calc - change accordingly

//local params:
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

//fixed multipliers:
const int	FIXED_POINT_MULTIPLIER	=	64;
const int	FIXED_SPEED_MULTIPLIER	=	64;
const int	FIXED_ANGLE_MULTIPLIER	=	256;
const int	FRICTION_INTENSITY	=	64;


// **GENERAL** logics
//logic enableCross ; //turned to output

// **WHITE BALL** logics
logic signed [31:0] WhiteBall_topLeftX_int, WhiteBall_topLeftY_int;
logic signed [31:0] WhiteBall_centerX_int, WhiteBall_centerY_int; //turned to outs

// **ANGLE AND SIN** logics
logic [7:0] Angle_8bit;
logic [7:0] Angle_Sin, Angle_Cos; 
logic [7:0] SinProd8_8tmpbit, CosProd8_8tmpbit; 
logic signed [15:0] SinProd16_Fixed, CosProd16_Fixed;
logic signed [31:0] Sin_Prod_abs, Cos_Prod_abs; //turned to outs
logic signed [31:0] Sin_Prod_Fixed, Cos_Prod_Fixed; //turned to outs

// **STRENGTH** logics
logic signed [31:0] Speed_strength_int; //turned to outs
logic signed [31:0] XShotSpeed_int, YShotSpeed_int; //turned to outs
logic signed [31:0] WhiteBall_Xspeed_OUT_int, WhiteBall_Yspeed_OUT_int; //turned to outs

// **CROSS LOCATION** logics
logic signed [31:0] Cross_topLeftX_int, Cross_topLeftY_int; //turned to outs


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


// sine and cosine components:
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

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) 
		begin
			Angle_8bit <= INITIAL_ANGLE;
			Speed_strength_int <= INITIAL_SPEED_STRENGTH;
						
			Cross_topLeftX_int <= WhiteBall_centerX_int - Cross_Size_Radius + ( (Cos_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
			Cross_topLeftY_int <= WhiteBall_centerY_int - Cross_Size_Radius + ( (Sin_Prod_Fixed*(WhiteBall_Radius + (Speed_strength_int/SPEED_STRENGTH_DIV_FOR_CROSS))) / FIXED_ANGLE_MULTIPLIER ) ;
			
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

endmodule
