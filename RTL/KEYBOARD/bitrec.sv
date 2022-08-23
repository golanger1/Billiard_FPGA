// (c) Technion IIT, Department of Electrical Engineering 2018 
// Written By David Bar-On  June 2018 

module bitrec 	
 ( 
	input	logic clk,
	input	logic resetN, 
	input	logic kbd_dat,
	input	logic kbd_clk,
	output  logic [7:0]	dout,	
	output  logic dout_new, 
	output  logic parity_ok
  ) ;


 enum  logic [2:0] {IDLE_ST, // initial state
					LOW_CLK_ST, // after clock low 
					HI_CLK_ST, // after clock hi 
					CHK_DATA_ST, // after all bits recieved 
					NEW_DATA_ST // valid parity laod new data 
					}  pres_st /* for simulation --> synthesis keep = 1 */, next_st  /* synthesis keep = 1 */;

  logic [3:0] cntr_PS,  cntr_NS /* for simulation -->synthesis keep = 1 */ ; 
  logic [9:0] shift_reg_PS, shift_reg_NS  /* for simulation -->synthesis keep = 1 */ ; 
  logic [7:0] Dout_NS  /* for simulation -->synthesis keep = 1 */ ; 
 
  
  localparam NUM_OF_BITS = 10 ; 

	always_ff @(posedge clk or negedge resetN)
	begin: fsm_sync_proc
		if (resetN == 1'b0) begin 
			pres_st <= IDLE_ST ; 
			cntr_PS <= 4'h0  ;
			shift_reg_PS <= 10'h000 ; 
			dout <= 8'h00 ;
			
			end 	
		else begin 
			pres_st <= next_st;
			cntr_PS <= cntr_NS ; 
			shift_reg_PS <= shift_reg_NS ;
			dout <= Dout_NS  ; 
		
		end ; 
	end // end fsm_sync_proc
  
always_comb 
begin
	// default values 
		next_st = pres_st ;
		cntr_NS = cntr_PS  ; 
		shift_reg_NS = shift_reg_PS  ;
		Dout_NS = dout ; 
		dout_new = 1'b0 ;

	 	

	case(pres_st)
			IDLE_ST: begin
//---------------
				cntr_NS = 4'h0  ;
				
				if( (kbd_clk == 1'b0) && (kbd_dat == 1'b0) ) 
					next_st = LOW_CLK_ST;
			end  
				
			LOW_CLK_ST: begin
//---------------
				if (kbd_clk == 1'b1)
					begin 
 						 shift_reg_NS = { kbd_dat,shift_reg_PS [9:1] }  ;  //shift right add new bit to the left 
						 if (cntr_PS < NUM_OF_BITS) 
						 begin 
								next_st = HI_CLK_ST;
								cntr_NS = cntr_PS + 4'h1  ; 

						 end 
						 else begin
								next_st = CHK_DATA_ST;
						 end 
					end 
			end  
				
			HI_CLK_ST: begin
//---------------
				if (kbd_clk == 1'b0)
					next_st = LOW_CLK_ST;
			end  
			
			CHK_DATA_ST: begin 
//---------------
				if (parity_ok == 1'b1 ) 
					begin 
						Dout_NS = shift_reg_PS [7:0] ; 
						next_st = NEW_DATA_ST ;
					end 
				else 
					next_st = IDLE_ST ;
			end  

			 NEW_DATA_ST: begin 
//---------------
					next_st = IDLE_ST ;
					dout_new = 1'b1 ; 
			end  
	
		endcase  
				
end 

// parity Calc 
//assign parity_ok = shift_reg_PS[8] ^ shift_reg_PS[7] ^ shift_reg_PS[6] ^ shift_reg_PS[5] ^ shift_reg_PS[3] 
//     ^ shift_reg_PS[2] ^ shift_reg_PS[1] ^ shift_reg_PS[1] ^ shift_reg_PS[0]; //-------- wrong parity

assign parity_ok = shift_reg_PS[8] ^ shift_reg_PS[7] ^ shift_reg_PS[6] ^ shift_reg_PS[5] ^ shift_reg_PS[4] 
      ^ shift_reg_PS[3] ^ shift_reg_PS[2] ^ shift_reg_PS[1] ^ shift_reg_PS[0]; //-------- correct parity


endmodule

