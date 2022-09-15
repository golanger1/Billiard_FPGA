
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021


`define NUM_BALLS 6 

module	balls_speed_calculator	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					input		logic	startOfFrame,
					
					input		logic [`NUM_BALLS:0] balls_collide,
					input		logic [1:0][3:0] Balls_col_ID,			// stores two IDS of the two collided balls, from lower ID to higher ID
					input		logic signed [`NUM_BALLS:0][10:0] Xspeed_VEC_in,		
					input		logic signed [`NUM_BALLS:0][10:0] Yspeed_VEC_in,
					input		logic signed [`NUM_BALLS:0][10:0] topLeftX_VEC_in, 	// needed to find the vector between the centers of the two balls
					input		logic signed [`NUM_BALLS:0][10:0] topLeftY_VEC_in,

					output	logic signed	[`NUM_BALLS:0][10:0] Xspeed_VEC_out,
				   output	logic signed	[`NUM_BALLS:0][10:0] Yspeed_VEC_out
		
);



localparam int MIN_Y_SPEED = 8; // exists also in movecollision - change accordingly
localparam int MIN_X_SPEED = 8; // exists also in movecollision - change accordingly
localparam int FIXED_SPEED_MULTIPLIER = 64; // exists also in movecollision - change accordingly

logic signed [10:0] X_diff;
logic signed [10:0] Y_diff;
logic signed [10:0] Xspeed_0, Yspeed_0;
logic signed [10:0] Xspeed_1, Yspeed_1;
logic signed [31:0] Xspeed0_out_int, Yspeed0_out_int, Xspeed1_out_int, Yspeed1_out_int; //needed



localparam int SQUARE_BALLS_CENTER_DIST = 1024; // 32*32

assign X_diff = int'(topLeftX_VEC_in[Balls_col_ID[1]] - topLeftX_VEC_in[Balls_col_ID[0]]);
assign Y_diff = int'(topLeftY_VEC_in[Balls_col_ID[1]] - topLeftY_VEC_in[Balls_col_ID[0]]);

assign Xspeed_0 = int'(Xspeed_VEC_in[Balls_col_ID[0]]);
assign Yspeed_0 = int'(Yspeed_VEC_in[Balls_col_ID[0]]);

assign Xspeed_1 = int'(Xspeed_VEC_in[Balls_col_ID[1]]);
assign Yspeed_1 = int'(Yspeed_VEC_in[Balls_col_ID[1]]);


always_comb
begin

			if ( (balls_collide[Balls_col_ID[0]] && balls_collide[Balls_col_ID[1]]) &&
					(Balls_col_ID[0] != Balls_col_ID[1] )) //&& flag == 1'b0 ) // make sure the ball IDs really match.
				begin

					Xspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
					Yspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};

					
					//calc ints of speed
					Xspeed0_out_int = ( ( ( Xspeed_0 - Xspeed_1 ) * Y_diff*Y_diff - ( Yspeed_0 - Yspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Xspeed_1; // u0x
					Yspeed0_out_int = ( ( ( Yspeed_0 - Yspeed_1 ) * X_diff*X_diff - ( Xspeed_0 - Xspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Yspeed_1; // u0y
					Xspeed1_out_int = ( ( ( Xspeed_0 - Xspeed_1 ) * X_diff*X_diff + ( Yspeed_0 - Yspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Xspeed_1; // u1x
					Yspeed1_out_int = ( ( ( Yspeed_0 - Yspeed_1 ) * Y_diff*Y_diff + ( Xspeed_0 - Xspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Yspeed_1; // u1y	
					
					// Xspeed0 boost
					if ( Xspeed0_out_int > 0 )
						begin
							Xspeed0_out_int = Xspeed0_out_int + MIN_X_SPEED;
						end
					else if ( Xspeed0_out_int < 0 )
						begin
							Xspeed0_out_int = Xspeed0_out_int - MIN_X_SPEED;
						end
					
					// Yspeed0 boost
					if ( Yspeed0_out_int > 0 )
						begin
							Yspeed0_out_int = Yspeed0_out_int + MIN_Y_SPEED;
						end
					else if ( Yspeed0_out_int < 0 )
						begin
							Yspeed0_out_int = Yspeed0_out_int - MIN_Y_SPEED;
						end
					
					// Xspeed1 boost
					if ( Xspeed1_out_int > 0 )
						begin
							Xspeed1_out_int = Xspeed1_out_int + MIN_X_SPEED;
						end
					else if ( Xspeed1_out_int < 0 )
						begin
							Xspeed1_out_int = Xspeed1_out_int - MIN_X_SPEED;
						end
					
					// Yspeed1 boost
					if ( Yspeed1_out_int > 0 )
						begin
							Yspeed1_out_int = Yspeed1_out_int + MIN_Y_SPEED;
						end
					else if ( Yspeed1_out_int < 0 )
						begin
							Yspeed1_out_int = Yspeed1_out_int - MIN_Y_SPEED;
						end
					// outs:
					Xspeed_VEC_out[Balls_col_ID[0]] = Xspeed0_out_int [10:0];
					Yspeed_VEC_out[Balls_col_ID[0]] = Yspeed0_out_int [10:0];
					Xspeed_VEC_out[Balls_col_ID[1]] = Xspeed1_out_int [10:0];
					Yspeed_VEC_out[Balls_col_ID[1]] = Yspeed1_out_int [10:0];
				end
			
			else
				begin

					Xspeed0_out_int = 0;
					Yspeed0_out_int = 0;
					Xspeed1_out_int = 0;
					Yspeed1_out_int = 0;
					Xspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
					Yspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};

				end
			
end

endmodule


