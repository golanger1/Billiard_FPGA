
// Implements the Sounds State Machine module, that controls the sounds in the project, 
// in accordance to the events arround it.

module Sounds_SM
	(
	input logic clk, 
	input logic resetN, 
	input logic startOfFrame,
	
	input logic winPulse,
	input logic losePulse,
	input logic collisionPulse,
	//input logic oneSecPulse,
	
	
	output logic enable_sound,
	output logic [3:0] freq
	);
	
	// state machine decleration 
	enum logic [2:0] {s_idle, s_win, s_lose, s_collision} sound_ps, sound_ns ;
	
	logic oneSecPulse;
	logic oneSecPulseOut;
	logic rst_cntN;
	
	logic [3:0] freq_ns, freq_ps;
	logic  enable_sound_ns, enable_sound_ps;
	logic  rst_cntN_ns, rst_cntN_ps;
	
	assign freq = freq_ps;
	assign enable_sound = enable_sound_ps;
	//assign rst_cntN = ( ~(~rst_cntN_ps | ~resetN) );
	assign rst_cntN = ( rst_cntN_ps &  resetN );
	assign oneSecPulse = oneSecPulseOut;
	
	
	one_sec_counter sec_counter( 
							.clk(clk), 
							.resetN( (rst_cntN) ),
							.turbo ( 1'b0 ),
							.one_sec( oneSecPulseOut )
							);
	
	always @(posedge clk or negedge resetN)
   begin
	   
		if ( !resetN )  // Asynchronic reset
			begin
				sound_ps <= s_idle;
				freq_ps <= 4'd0;
				enable_sound_ps <= 1'b0;
				rst_cntN_ps <= 1'b1;
			end
		
		else 		// Synchronic logic FSM
			begin
				sound_ps <= sound_ns;
				freq_ps <= freq_ns;
				enable_sound_ps <= enable_sound_ns;
				rst_cntN_ps <= rst_cntN_ns;
			end
	end // always sync
	
	
	
	always_comb // Update next state and outputs
	begin
	// set all default values 
		sound_ns = sound_ps; 
		freq_ns = freq_ps;
			
		case (sound_ps)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin
				enable_sound_ns = 1'b0; 
				rst_cntN_ns = 1'b1;
				
				if ( collisionPulse == 1'b1 )
					begin
						enable_sound_ns = 1'b1;
						sound_ns = s_collision;
						rst_cntN_ns = 1'b0;
					end
				else if ( winPulse == 1'b1 )
					begin
						enable_sound_ns = 1'b1;
						sound_ns = s_win;
						rst_cntN_ns = 1'b0;
					end
				else if ( losePulse == 1'b1 )
					begin
						enable_sound_ns = 1'b1;
						sound_ns = s_lose;
						rst_cntN_ns = 1'b0;
					end
				end // idle
						
						
			s_win: begin
				freq_ns = 4'd9;
				rst_cntN_ns = 1'b1;
				enable_sound_ns = 1'b1;
				
				if ( oneSecPulse == 1'b1 ) // if one second passed
					begin
						enable_sound_ns = 1'b0;
						rst_cntN_ns = 1'b0;
						sound_ns = s_idle;
					end
				end // win
				
			
			s_lose: begin
				freq_ns = 4'd1;
				rst_cntN_ns = 1'b1;
				enable_sound_ns = 1'b1;
				
				if ( oneSecPulse == 1'b1 ) // if one second passed
					begin
						enable_sound_ns = 1'b0;
						rst_cntN_ns = 1'b0;
						sound_ns = s_idle;
					end
				
				end // lose
			
			
			s_collision: begin
				freq_ns = 4'd5;
				rst_cntN_ns = 1'b1;
				enable_sound_ns = 1'b1;
				
				if ( winPulse == 1'b1 ) // if won
					begin
						sound_ns = s_win;
						rst_cntN_ns = 1'b0;
					end
				else if ( losePulse == 1'b1 )// if lose
					begin
						sound_ns = s_lose;
						rst_cntN_ns = 1'b0;
					end
				else if ( collisionPulse == 1'b1 ) // if collision
					begin
						rst_cntN_ns = 1'b0;
					end
				else if ( oneSecPulse == 1'b1 ) // if one second passed
					begin
						enable_sound_ns = 1'b0;
						sound_ns = s_idle;
						rst_cntN_ns = 1'b0;
					end
				end // collide
						
		endcase
		
	end // always comb
	
endmodule
