
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

//// change for signalTap					
//					output logic signed [31:0] calc_diff_Xspeed0_Xspeed1,
//					output logic signed [31:0] calc_left_multiply,
//					output logic signed [31:0] calc_diff_Yspeed0_Yspeed1,
//					output logic signed [31:0] calc_right_multiply,
//					output logic signed [31:0] calc_first_sum,
//					output logic signed [31:0] calc_shift10,
//					output logic signed [31:0] calc_final_int,
//					output logic signed [10:0] calc_final_11bit,
//					output logic signed [10:0] X_diff,
//					output logic signed [10:0] Y_diff,
//					output logic signed [10:0] Xspeed_0,
//					output logic signed [10:0] Yspeed_0,
//					output logic signed [10:0] Xspeed_1,
//					output logic signed [10:0] Yspeed_1,
//					output logic signed [31:0] Xspeed0_out_int, //needed
//					output logic signed [31:0] Yspeed0_out_int, //needed
//					output logic signed [31:0] Xspeed1_out_int, //needed
//					output logic signed [31:0] Yspeed1_out_int, //needed
//					output logic signed [`NUM_BALLS:0][10:0] Xspeed_VEC_out_test0,
//					output logic signed [`NUM_BALLS:0][10:0] Xspeed_VEC_out_test1,
//					output logic signed [0:`NUM_BALLS][10:0] Xspeed_VEC_out_test2
					
);

//logic flag_counter; 
//logic flag; 

//// change for signalTap					
logic signed [10:0] X_diff;
logic signed [10:0] Y_diff;
logic signed [10:0] Xspeed_0, Yspeed_0;
logic signed [10:0] Xspeed_1, Yspeed_1;
logic signed [31:0] Xspeed0_out_int, Yspeed0_out_int, Xspeed1_out_int, Yspeed1_out_int; //needed


////not needed currently:
//int Xspeed_0_int, Yspeed_0_int, Xspeed_1_int, Yspeed_1_int;
////int Xspeed_VEC_calc [`NUM_BALLS:0];
////int Yspeed_VEC_calc [`NUM_BALLS:0];

localparam int SQUARE_BALLS_CENTER_DIST = 1024; // 32*32

assign X_diff = int'(topLeftX_VEC_in[Balls_col_ID[1]] - topLeftX_VEC_in[Balls_col_ID[0]]);
assign Y_diff = int'(topLeftY_VEC_in[Balls_col_ID[1]] - topLeftY_VEC_in[Balls_col_ID[0]]);

////assign X_diff_int = { {21{X_diff[10]}}, X_diff[10:0]};
////assign Y_diff_int = { {21{Y_diff[10]}}, Y_diff[10:0]};

assign Xspeed_0 = int'(Xspeed_VEC_in[Balls_col_ID[0]]);
////assign Xspeed_0_int = { {21{Xspeed_0[10]}}, Xspeed_0[10:0]};
assign Yspeed_0 = int'(Yspeed_VEC_in[Balls_col_ID[0]]);
////assign Yspeed_0_int = { {21{Yspeed_0[10]}}, Yspeed_0[10:0]};

assign Xspeed_1 = int'(Xspeed_VEC_in[Balls_col_ID[1]]);
////assign Xspeed_1_int = { {21{Xspeed_1[10]}}, Xspeed_1[10:0]};
assign Yspeed_1 = int'(Yspeed_VEC_in[Balls_col_ID[1]]);
////assign Yspeed_1_int = { {21{Yspeed_1[10]}}, Yspeed_1[10:0]};


//// change for signalTap					
//logic signed [31:0] calc_diff_Xspeed0_Xspeed1;
//logic signed [31:0] calc_left_multiply;
//logic signed [31:0] calc_diff_Yspeed0_Yspeed1;
//logic signed [31:0] calc_right_multiply;
//logic signed [31:0] calc_first_sum;
//logic signed [31:0] calc_shift10;
//logic signed [31:0] calc_final_int;
//logic signed [10:0] calc_final_11bit;


//assign Xspeed_VEC_out = Xspeed_VEC_calc[10:0];
//assign Yspeed_VEC_out = Yspeed_VEC_calc[10:0];

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
					////Xspeed_VEC_calc = {(`NUM_BALLS+1){0}};
					////Yspeed_VEC_calc = {(`NUM_BALLS+1){0}};
					Xspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
					Yspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
//					Xspeed_VEC_out_test0 = {(`NUM_BALLS+1){11'b0}};
//					Xspeed_VEC_out_test1 = {(`NUM_BALLS+1){11'b0}};
//					Xspeed_VEC_out_test2 = {(`NUM_BALLS+1){11'b0}};
					
					////Xspeed_VEC_calc[Balls_col_ID[0]] = ( ( ( Xspeed_0_int - Xspeed_1_int ) * Y_diff_int*Y_diff_int - ( Yspeed_0_int - Yspeed_1_int ) * Y_diff_int*X_diff_int ) >>> 10 ) + Xspeed_1_int; // u0x
					Xspeed0_out_int = ( ( ( Xspeed_0 - Xspeed_1 ) * Y_diff*Y_diff - ( Yspeed_0 - Yspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Xspeed_1; // u0x
					Xspeed_VEC_out[Balls_col_ID[0]] = Xspeed0_out_int [10:0];
					
					////Yspeed_VEC_calc[Balls_col_ID[0]] = ( ( ( Yspeed_0_int - Yspeed_1_int ) * X_diff_int*X_diff_int - ( Xspeed_0_int - Xspeed_1_int ) * Y_diff_int*X_diff_int ) >>> 10 ) + Yspeed_1_int;	    // u0y
					Yspeed0_out_int = ( ( ( Yspeed_0 - Yspeed_1 ) * X_diff*X_diff - ( Xspeed_0 - Xspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Yspeed_1;	    // u0y
					Yspeed_VEC_out[Balls_col_ID[0]] = Yspeed0_out_int [10:0];
					
					
					// Balls_col_ID[1] is the ball with the higher ID
					
					// DEBUG u1x ( Xspeed_VEC_out[Balls_col_ID[1]] )
					////Xspeed_VEC_calc[Balls_col_ID[1]] = ( ( ( Xspeed_0_int - Xspeed_1_int ) * X_diff_int*X_diff_int + ( Yspeed_0_int - Yspeed_1_int ) * Y_diff_int*X_diff_int ) >>> 10 ) + Xspeed_1_int;	// u1x
//					calc_diff_Xspeed0_Xspeed1 = Xspeed_0 - Xspeed_1;
//					calc_left_multiply = calc_diff_Xspeed0_Xspeed1*X_diff*X_diff;
//					calc_diff_Yspeed0_Yspeed1 = Yspeed_0 - Yspeed_1;
//					calc_right_multiply = calc_diff_Yspeed0_Yspeed1*Y_diff*X_diff;
//					calc_first_sum = calc_left_multiply + calc_right_multiply;
//					calc_shift10 = calc_first_sum >>> 10;
//					calc_final_int = calc_shift10 + Xspeed_1;
//					calc_final_11bit = calc_final_int [10:0];
					
					//needed:
					Xspeed1_out_int = (((((Xspeed_0 - Xspeed_1 )*X_diff*X_diff) + (( Yspeed_0 - Yspeed_1 )*Y_diff*X_diff))>>>10) + Xspeed_1); // u1x
					Xspeed_VEC_out[Balls_col_ID[1]] = Xspeed1_out_int [10:0];
					
//					Xspeed_VEC_out_test0[Balls_col_ID[1]] = calc_final_int [10:0];
//					Xspeed_VEC_out_test1[Balls_col_ID[1]] = Xspeed1_out_int [10:0];
//					Xspeed_VEC_out_test2[Balls_col_ID[1]] = calc_final_int [10:0];
					
					
					////Yspeed_VEC_calc[Balls_col_ID[1]] = ( ( ( Yspeed_0_int - Yspeed_1_int ) * Y_diff_int*Y_diff_int + ( Xspeed_0_int - Xspeed_1_int ) * Y_diff_int*X_diff_int ) >>> 10 ) + Yspeed_1_int;	// u1y	
					Yspeed1_out_int = ( ( ( Yspeed_0 - Yspeed_1 ) * Y_diff*Y_diff + ( Xspeed_0 - Xspeed_1 ) * Y_diff*X_diff ) >>> 10 ) + Yspeed_1;	// u1y	
					Yspeed_VEC_out[Balls_col_ID[1]] = Yspeed1_out_int [10:0];
					////Xspeed_VEC_out[Balls_col_ID[0]] = Xspeed_VEC_calc[Balls_col_ID[0]][10:0];
					////Yspeed_VEC_out[Balls_col_ID[0]] = Yspeed_VEC_calc[Balls_col_ID[0]][10:0];
					////Xspeed_VEC_out[Balls_col_ID[1]] = Xspeed_VEC_calc[Balls_col_ID[1]][10:0];
					////Yspeed_VEC_out[Balls_col_ID[1]] = Yspeed_VEC_calc[Balls_col_ID[1]][10:0];
					// counter ++
					//flag <= 1'b1;
				end
			else
				begin
					////Xspeed_VEC_calc = {(`NUM_BALLS+1){0}};
					////Yspeed_VEC_calc = {(`NUM_BALLS+1){0}};
					Xspeed0_out_int = 0;
					Yspeed0_out_int = 0;
					Xspeed1_out_int = 0;
					Yspeed1_out_int = 0;
					Xspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
					Yspeed_VEC_out = {(`NUM_BALLS+1){11'b0}};
					
////				DEBUG - need to remove:
//					Xspeed_VEC_out_test0 = {(`NUM_BALLS+1){11'b0}};
//					Xspeed_VEC_out_test1 = {(`NUM_BALLS+1){11'b0}};
//					Xspeed_VEC_out_test2 = {(`NUM_BALLS+1){11'b0}};
//					calc_diff_Xspeed0_Xspeed1 = 0;
//					calc_left_multiply = 0;
//					calc_diff_Yspeed0_Yspeed1 = 0;
//					calc_right_multiply = 0;
//					calc_first_sum = 0;
//					calc_shift10 = 0;
//					calc_final_int = 0;
//					calc_final_11bit = {11'b0};
					//calc_final_int_allinone = 0;

				end
			
//		end
end

endmodule


