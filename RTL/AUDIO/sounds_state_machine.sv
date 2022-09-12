
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
	
	
	output logic enable_sound,
	output logic [3:0] freq
	);
	
	// state machine decleration 
	enum logic [2:0] {s_idle, s_win, s_lose, s_collision} sound_ps, sound_ns ;
	
	logic [3:0] freq_ns, freq_ps;
	
	assign freq = freq_ps;
	
	logic oneSecPulse;
	logic rst_cntN;
	
	one_sec_counter sec_counter( 
							.clk(clk), 
							.resetN( (rst_cntN | resetN) ),
							.one_sec( oneSecPulse )
							);
	
	always @(posedge clk or negedge resetN)
   begin
	   
		if ( !resetN )  // Asynchronic reset
			sound_ps <= s_idle;
		
		else 		// Synchronic logic FSM
			sound_ps <= sound_ns;
			freq_ps <= freq_ns;
	end // always sync
	
	
	
	always_comb // Update next state and outputs
	begin
	// set all default values 
		sound_ns = sound_ps; 
		enable_sound = 1'b0; 
		rst_cntN = 1'b0;
		
		freq_ns = freq_ps;
			
		case (sound_ps)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin
				
				if ( collisionPulse == 1'b1 )
					begin
						sound_ns = s_collision;
					end
				else if ( winPulse == 1'b1 )
					begin
						sound_ns = s_win;
					end
				else if ( losePulse == 1'b1 )
					begin
						sound_ns = s_lose;
					end
				end // idle
						
						
			s_win: begin
				freq_ns = 4'd9;
				enable_sound = 1'b1;
				rst_cntN = 1'b1;
				
				
				if ( oneSecPulse ) // if one sec didn't pass
					begin
						sound_ns = s_idle;
					end
				end // win
				
			
			s_lose: begin
				freq_ns = 4'd1;
				enable_sound = 1'b1;
				rst_cntN = 1'b1;
				
				if ( oneSecPulse )// if one sec didn't pass
					begin
						sound_ns = s_idle;
					end
				
				end // lose
			
			
			s_collision: begin
				freq_ns = 4'd5;
				enable_sound = 1'b1;
				rst_cntN = 1'b1;
				
				if ( winPulse == 1'b1 ) // if won
					begin
						rst_cntN = 1'b0;
						sound_ns = s_win;
					end
				else if ( losePulse == 1'b1 )// if lose
					begin
						rst_cntN = 1'b0;
						sound_ns = s_lose;
					end
				else if ( collisionPulse == 1'b1 ) // if collision
					begin
						rst_cntN = 1'b0;
					end
				else if ( oneSecPulse ) // if one sec didn't pass
					begin
						sound_ns = s_idle;
					end
				end // collide
						
		endcase
		
	end // always comb
	
endmodule
