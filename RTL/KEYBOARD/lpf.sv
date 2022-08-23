// (c) Technion IIT, Department of Electrical Engineering 2021
// Written By David Bar-On  June 2018 
// filters the output, ignores short glitches in the input 

module lpf 	
 #(parameter FILTER_SIZE = 4)
 
 ( 
 	input	   logic  clk,
	input	   logic  resetN, 
	input	   logic  in,
	
   output  logic 	out_filt	
 
  ) ;


 enum  logic [1:0] {ONE, ZERO}  nxt_st, cur_st; // one bit holding the two states 

  logic [FILTER_SIZE-1:0] cntr, cntr_ns ; 

	always_ff @(posedge clk or negedge resetN)
	begin
		if (resetN == 1'b0) begin 
			cur_st <= ZERO ; 
			cntr <= {FILTER_SIZE{1'b0}}; ;
			end 	
		else begin 
			cur_st <= nxt_st;
			cntr <= cntr_ns ; 
		end ; 
	end // end fsm_sync_proc
 

 // the counter isincrementted every clock, if the are enought ones, or zeros then the state changes 
 
 // Asynchronous Process
	always_comb 
	begin
		
		// default values 
		cntr_ns = cntr   ; 
		nxt_st = cur_st  ;
		
		if (in == 1'b1) begin 
			if (cntr <  {FILTER_SIZE{1'b1}} ) //bit extension to as many ones as needed  
					cntr_ns = cntr + 1 ; // increment the counterif the input is one 
			else 
					nxt_st = ONE;
		end
		else begin 
			if (cntr >  {FILTER_SIZE{1'b0}} )
					cntr_ns = cntr - 1 ; 
			else  
				nxt_st = ZERO;
		end ; 

		
	end // end fsm_async_proc
 
 	
	// decoding the state to output logic 		
	
	 assign out_filt =  (cur_st == ONE) ? 1'b1 :  1'b0 ;	

endmodule


