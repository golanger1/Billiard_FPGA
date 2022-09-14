// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1,
	input logic enable2, 
	input logic enable3, 
	input logic [3:0] datain,
	
	output logic [3:0] count,
	output logic tc
   );

// Down counter
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'b0;
			
		end
				
      else 	begin		// Synchronic logic		
			
			if ( !loadN ) begin
				count = datain;
			end
			
			else begin
				if ( enable1 && enable2 && enable3 ) 
					begin
						if ( count == 4'b0 ) 
							begin
								count <= 4'h9;
							end
						else
							begin
								count <= count - 4'd1;
							end
					end
			end
		end //Synch
	end //always
	
	// Asynchronic tc
	
	assign tc = (count == 4'b0);
	
endmodule
