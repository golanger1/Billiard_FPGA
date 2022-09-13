
// Implements the Sounds State Machine module, that controls the sounds in the project, 
// in accordance to the events arround it.

`define NUM_BALLS 2 

module game_controller_SM
	(
	input 	logic clk, 
	input 	logic resetN, 
	input 	logic startOfFrame,
	
	input 	logic [`NUM_BALLS:0] balls_in_game,
	input 	logic [`NUM_BALLS:0] ballhole_collide, // TODO: need to add ballhole output from the hit unit
	input		logic [2:0] curr_Hole_id,
	
	

	input 	logic collisionPulse,
	
	output 	logic winPulse,
	output 	logic losePulse,	
	
	output 	logic [2:0] request_hole,
	output 	logic [3:0] scoreL,
	output 	logic [3:0] scoreH,
	output	logic	[3:0] stage_num
	);
	
	// state machine decleration 
	enum logic [2:0] {s_idle, s_stage_1, s_stage_2, s_win, s_lose, s_scored} game_ps, game_ns ;
	
	logic oneSecPulseOut;
	logic rst_cntN;
	
	
	logic  rst_cntN_ns, rst_cntN_ps;
	logic [3:0] stage_num_ns, stage_num_ps;
	
	logic timeLoadN_ns, timeLoadN_ps;
	logic scoreLoadN_ns, scoreLoadN_ps;
	logic stageLoadN_ns, stageLoadN_ps;
	
	logic winPulse_ns, winPulse_ps;
	logic losePulse_ns, losePulse_ps;
	
	logic change_stage_ns, change_stage_ps;
	logic score_up_ns, score_up_ps;

	
	assign winPulse = winPulse_ps;
	assign losePulse = losePulse_ps;
	assign rst_cntN = ( rst_cntN_ps &  resetN );
	assign oneSecPulse = oneSecPulseOut;
	assign stage_num = stage_num_ps;
	
	
	logic [3:0] scoreLowLoad;
	logic [3:0] scoreHighLoad;

	logic [3:0] seconds_to_load;
	
	logic [3:0] timeCounter;
	
//	logic scoreLoadN;
//	logic stageLoadN;
//	logic timeLoadN;

	logic finished_counting;
	
	
	
	one_sec_counter sec_counter( 
							.clk(clk), 
							.resetN( (rst_cntN) ),
							.turbo ( 1'b0 ),
							.one_sec( oneSecPulseOut )
							);
							
	down_counter time_counter (
							.clk( clk ), 
							.resetN( resetN ),
							.loadN( timeLoadN_ps ),
							.enable1( oneSecPulseOut ),
							.enable2( oneSecPulseOut ),
							.enable3( oneSecPulseOut ),
							.datain( seconds_to_load ),
							.count( timeCounter ),			// output
							.tc( finished_counting )		// output
	);
	
	up_counter stage_counter (
							.clk( clk ), 
							.resetN( resetN ),
							.loadN( stageLoadN_ps ),
							.enable1( change_stage ),
							.enable2( change_stage ),
							.enable3( change_stage ),
							.datain( stage_num_ps ),
							.count( stage_num ),	// output
							.tc(  )		// output
	);
	
	two_digits_decimal_up_counter score_counter (
											.clk( clk ), 
											.resetN( resetN ),
											.loadN( scoreLoadN_ps ),
											.enable1( score_up ),
											.enable2( score_up ),
											.datainL( scoreLowLoad ),
											.datainH( scoreHighLoad ),
											.countL( scoreL ),	// output
											.countH( scoreH ),	// output
											.tc(  )			// output
											
	);
	
	always @(posedge clk or negedge resetN)
   begin
	   
		if ( !resetN )  // Asynchronic reset
			begin
				game_ps <= s_idle;
				rst_cntN_ps 	<= 1'b1;
				stage_num_ps 	<= 4'd1;
				timeLoadN_ps 	<= 1'b1;
				scoreLoadN_ps 	<= 1'b1;
				stageLoadN_ps 	<= 1'b1;
				winPulse_ns		<= winPulse_ps;
				losePulse_ns	<= losePulse_ps;
				score_up_ns 	<= score_up_ps;
				change_stage_ns <= change_stage_ps;
				//count_seconds_ps <= 1'b0;
			end
		
		else 		// Synchronic logic FSM
			begin
				game_ps <= game_ns;
				stage_num_ps 	<= stage_num_ns;
				rst_cntN_ps 	<= rst_cntN_ns;
				//count_seconds_ps <= count_seconds_ns;
				timeLoadN_ps 	<= timeLoadN_ns;
				scoreLoadN_ps 	<= scoreLoadN_ns;
				stageLoadN_ps 	<= stageLoadN_ns;
				winPulse_ps		<= winPulse_ns;
				losePulse_ps	<= losePulse_ns;
				score_up_ps 	<= score_up_ns;
				change_stage_ps <= change_stage_ns;
			end
	end // always sync
	
	
	
	always_comb // Update next state and outputs
	begin
	// set all default values 
		game_ns 			= game_ps; 
		stage_num_ns 	= stage_num_ps;
		rst_cntN_ns 	= rst_cntN_ps;
		timeLoadN_ns 	= timeLoadN_ps;
		scoreLoadN_ns	= scoreLoadN_ps;
		stageLoadN_ns	= stageLoadN_ps;
		
		winPulse_ns 	= winPulse_ps;
		losePulse_ns 	= losePulse_ps;
		request_hole 	= 3'b0;
		
//		scoreLoadN = 1'b1;
//		stageLoadN = 1'b1;
//		timeLoadN = 1'b1;
		
//		scoreHighLoad 	= 4'd0;
//		scoreLowLoad 	= 4'd0;
		seconds_to_load =  4'd0;
		
		
		score_up_ns 		= 1'b0;
		change_stage_ns 	= 1'b0;
		
			
		case (game_ps)
		
		s_idle: begin
				rst_cntN_ns = 1'b1;
				
				if ( ballhole_collide[(`NUM_BALLS):1] != {(`NUM_BALLS){1'b0}} ) // scored!
					begin
						game_ns = s_scored;
					end
				else if ( balls_in_game[(`NUM_BALLS):1] == {(`NUM_BALLS){1'b0}} ) // if only white stayed in game
					begin
						game_ns = s_win;
						rst_cntN_ns = 1'b0;
					end
				else if ( ballhole_collide[0] == 1'b1 ) // white is out, lost
					begin
						game_ns = s_lose;
						rst_cntN_ns = 1'b0;
					end
				end // idle
			
			s_stage_1: begin
				/// make stage 1 setup ///
				stage_num_ns = 4'd1;
			end // stage 1
			
			s_stage_2: begin
			/// make stage 2 setup ///
				
				stage_num_ns = 4'd2;
			end // stage 2
						
						
			s_win: begin
			
				if ( winPulse_ps != 1'b1 )		
					begin	
						rst_cntN_ns = 1'b1; // turn reset off
						timeLoadN_ns = 1'b0; // load
						seconds_to_load = 4'd2; // load two seconds
						winPulse_ns = 1'b1; 
					end
				
				
				if ( finished_counting == 1'b1 ) 
					begin
						winPulse_ns = 1'b0; 
						game_ns = s_idle;
					end
				end // win
				
			
			s_lose: begin
				
			if ( losePulse_ps != 1'b1 )		
					begin	
						rst_cntN_ns = 1'b1; // turn reset off
						timeLoadN_ns = 1'b0; // load
						seconds_to_load = 4'd3; // load three seconds
						losePulse_ns = 1'b1;
					end
				
				
				if ( finished_counting == 1'b1 ) 
					begin
						losePulse_ns = 1'b0;
						game_ns = s_idle;
					end
				end	// lose
			
			
			s_scored: begin
//				rst_cntN_ns = 1'b1;
				score_up_ns = 1'b1;
				game_ns = s_idle;
				
//				if ( winPulse == 1'b1 ) // if won
//					begin
//						game_ns = s_win;
//						rst_cntN_ns = 1'b0;
//					end
//				else if ( losePulse == 1'b1 ) // if lose
//					begin
//						game_ns = s_lose;
//						rst_cntN_ns = 1'b0;
//					end
//				else if ( collisionPulse == 1'b1 ) // if collision
//					begin
//						rst_cntN_ns = 1'b0;
//					end
//				else if ( oneSecPulse == 1'b1 ) // if one second passed
//					begin
//						game_ns = s_idle;
//						rst_cntN_ns = 1'b0;
//					end
				end // collide
						
		endcase
		
	end // always comb
	
endmodule
