
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021


`define NUM_BALLS 2 

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

//logic flag_counter; 
//logic flag; 

logic signed [10:0] X_diff;
logic signed [10:0] Y_diff;
int Xspeed_0, Yspeed_0;
int Xspeed_1, Yspeed_1;

localparam int SQUARE_BALLS_CENTER_DIST = 1024; // 32*32

assign X_diff = topLeftX_VEC_in[Balls_col_ID[1]] - topLeftX_VEC_in[Balls_col_ID[0]];
assign Y_diff = topLeftY_VEC_in[Balls_col_ID[1]] - topLeftY_VEC_in[Balls_col_ID[0]];

assign X_diff_int = { {21{X_diff[10]}}, X_diff[10:0]};
assign Y_diff_int = { {21{Y_diff[10]}}, Y_diff[10:0]};


assign Xspeed_0 = Xspeed_VEC_in[Balls_col_ID[0]];
assign Yspeed_0 = Yspeed_VEC_in[Balls_col_ID[0]];

assign Xspeed_1 = Xspeed_VEC_in[Balls_col_ID[1]];
assign Yspeed_1 = Yspeed_VEC_in[Balls_col_ID[1]];

always_comb
begin
//	if(!resetN) 
//		begin
//			Xspeed_VEC_out	= {(`NUM_BALLS+1){11'b0}};
//			Yspeed_VEC_out	= {(`NUM_BALLS+1){11'b0}};
//			//flag_counter <= 1'b0;
//			//flag <= 1'b0;	
//		end
//	
//	else 
//		begin 
//			
			if ( (balls_collide[Balls_col_ID[0]] && balls_collide[Balls_col_ID[1]]) &&
					(Balls_col_ID[0] != Balls_col_ID[1] )) //&& flag == 1'b0 ) // make sure the ball IDs really match.
				begin
					Xspeed_VEC_out[Balls_col_ID[0]][10:0] = ( ( ( ( Xspeed_0 - Xspeed_1 ) * Y_diff_int*Y_diff_int - ( Yspeed_0 - Yspeed_1 ) * Y_diff_int*X_diff_int ) >>> 10 ) + Xspeed_1 ); // u0x
					Yspeed_VEC_out[Balls_col_ID[0]][10:0] = ( ( ( Yspeed_0 - Yspeed_1 ) * X_diff_int*X_diff_int - ( Xspeed_0 - Xspeed_1 ) * Y_diff_int*X_diff_int ) >>> 10 ) + Yspeed_1;	    // u0y
					// Balls_col_ID[1] is the ball with the higher ID
					Xspeed_VEC_out[Balls_col_ID[1]][10:0] = ( ( ( Xspeed_0 - Xspeed_1 ) * X_diff_int*X_diff_int + ( Yspeed_0 - Yspeed_1 ) * Y_diff_int*X_diff_int ) >>> 10 ) + Xspeed_1;	// u1x
					Yspeed_VEC_out[Balls_col_ID[1]][10:0] = ( ( ( Yspeed_0 - Yspeed_1 ) * Y_diff_int*Y_diff_int + ( Xspeed_0 - Xspeed_1 ) * Y_diff_int*X_diff_int ) >>> 10 ) + Yspeed_1;	// u1y									
					// counter ++
					//flag <= 1'b1;
				end
			
//		end
end

endmodule


