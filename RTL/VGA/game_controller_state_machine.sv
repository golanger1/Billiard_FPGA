
// Implements the Sounds State Machine module, that controls the sounds in the project, 
// in accordance to the events arround it.

`define NUM_BALLS 6 
`define FINAL_STAGE 4'd6 //4'd4 

module game_controller_SM
	(
	input 	logic clk, 
	input 	logic resetN, 
	input 	logic startOfFrame,
	input		logic	cheat,

	
	input 	logic [`NUM_BALLS:0] balls_in_game,
	input 	logic [`NUM_BALLS:0] ballhole_collide, // TODO: need to add ballhole output from the hit unit
	input		logic [2:0] curr_Hole_id,
	
	

	//input 	logic collisionPulse,
	
	output 	logic winPulse,
	output 	logic losePulse,	
	output 	logic scoredPulse,
	
	output 	logic [2:0] request_hole,
	output 	logic [3:0] scoreL,
	output 	logic [3:0] scoreH,
	output	logic	[3:0] stage_num
	);
	
	// state machine decleration 
	typedef enum logic [3:0] {s_idle, s_stage_1, s_stage_2, s_stage_3, s_stage_4, s_stage_5, s_stage_6, /***  ***/ s_win, s_lose, s_scored, s_missed} game_states_e ;
	
	game_states_e game_ps, game_ns;
	
	logic oneSecPulseOut;
	logic rst_cntN;
	
	
	logic  rst_cntN_ns, rst_cntN_ps;
	logic [3:0] stage_num_ns, stage_num_ps;
	
	logic timeLoadN_ns, timeLoadN_ps;
	logic scoreLoadN_ns, scoreLoadN_ps;
	logic stageLoadN_ns, stageLoadN_ps;
	
	logic winPulse_ns, winPulse_ps;
	logic losePulse_ns, losePulse_ps;
	logic scoredPulse_ns, scoredPulse_ps;
	logic [2:0] request_hole_ps, request_hole_ns;
	
	logic change_stage_ns, change_stage_ps;
	logic score_up_ns, score_up_ps;
	
	logic wonFlag_ns, wonFlag_ps;
	logic lostFlag_ns, lostFlag_ps;

	
	assign winPulse = winPulse_ps;
	assign losePulse = losePulse_ps;
	assign rst_cntN = ( rst_cntN_ps &  resetN );
	assign oneSecPulse = oneSecPulseOut;
	assign stage_num = stage_num_ps;
	assign scoreL = scoreLowLoad_ps;
	assign scoreH = scoreHighLoad_ps;

	assign request_hole = request_hole_ps;
	
	
	logic [3:0] scoreLowLoad_ns, scoreLowLoad_ps;
	logic [3:0] scoreHighLoad_ns, scoreHighLoad_ps;

	logic [3:0] seconds_to_load;
	
	logic [3:0] timeCounter;

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
	
	/*** up_counter stage_counter (
							.clk( clk ), 
							.resetN( resetN ),
							.loadN( stageLoadN_ps ),
							.enable1( change_stage_ps ),
							.enable2( change_stage_ps ),
							.enable3( change_stage_ps ),
							.datain( stage_num_ps ),
							.count( stage_num ),	// output
							.tc(  )		// output
							
	);***/
	
	/***two_digits_decimal_up_counter score_counter (
											.clk( clk ), 
											.resetN( resetN ),
											.loadN( scoreLoadN_ps ),
											.enable1( score_up_ps ),
											.enable2( score_up_ps ),
											.datainL( scoreLowLoad_ps ),
											.datainH( scoreHighLoad_ps ),
											.countL( scoreL ),	// output
											.countH( scoreH ),	// output
											.tc(  )			// output
											
	);***/
	
	always @(posedge clk or negedge resetN)
   begin
	   
		if ( !resetN )  // Asynchronic reset
			begin
				game_ps <= s_idle;
				rst_cntN_ps 	<= 1'b1;
				stage_num_ps 	<= 4'd0;
				
				timeLoadN_ps 	<= 1'b1;
				scoreLoadN_ps 	<= 1'b1;
				stageLoadN_ps 	<= 1'b1;
				
				winPulse_ps		<= 1'b0;
				losePulse_ps	<= 1'b0;
				scoredPulse_ps	<= 1'b0;
				
				request_hole_ps <= 3'd0;
				score_up_ps 	<= 1'b0;
				change_stage_ps <= 1'b1;
				
				wonFlag_ps		<= 1'b0;
				lostFlag_ps		<= 1'b0;
				
				scoreHighLoad_ps <= 4'd0;
				scoreLowLoad_ps  <= 4'd0;
				
				//count_seconds_ps <= 1'b0;
			end
		
		else 		// Synchronic logic FSM
			begin
				game_ps 			<= game_ns;
				stage_num_ps 	<= stage_num_ns;
				rst_cntN_ps 	<= rst_cntN_ns;
				//count_seconds_ps <= count_seconds_ns;
				timeLoadN_ps 	<= timeLoadN_ns;
				scoreLoadN_ps 	<= scoreLoadN_ns;
				stageLoadN_ps 	<= stageLoadN_ns;
				winPulse_ps		<= winPulse_ns;
				losePulse_ps	<= losePulse_ns;
				scoredPulse_ps <= scoredPulse_ns;
				request_hole_ps <= request_hole_ns;
				score_up_ps 	<= score_up_ns;
				change_stage_ps <= change_stage_ns;
				wonFlag_ps		<= wonFlag_ns;
				lostFlag_ps		<= lostFlag_ns;
				
				scoreHighLoad_ps <= scoreHighLoad_ns;
				scoreLowLoad_ps  <= scoreLowLoad_ns;
			end
	end // always sync
	
	
	
	always_comb // Update next state and outputs
	begin
	// set all default values 
		game_ns 			= game_ps; 
		stage_num_ns 	= stage_num_ps;
		rst_cntN_ns 	= rst_cntN_ps;
		timeLoadN_ns 	= timeLoadN_ps;
		scoreLoadN_ns	= 1'b1;
		stageLoadN_ns	= stageLoadN_ps;
		
		winPulse_ns 	= winPulse_ps;
		losePulse_ns 	= losePulse_ps;
		scoredPulse_ns = 1'b0;
		request_hole_ns = request_hole_ps;
		
		scoreHighLoad_ns 	= scoreHighLoad_ps;
		scoreLowLoad_ns 	= scoreLowLoad_ps;
		seconds_to_load 	=  4'd0;
		
		
		score_up_ns 		= 1'b0;
		change_stage_ns 	= 1'b0;
		
		wonFlag_ns			= wonFlag_ps;
		lostFlag_ns 		= lostFlag_ps;
		
		
			
		case (game_ps)
		
		s_idle: begin
				rst_cntN_ns = 1'b1;
				
				if ( cheat && !lostFlag_ps && !wonFlag_ps )
					begin
						change_stage_ns = 1'b1;
					end
				
				if ( change_stage_ps )
					begin
						//$cast(game_ns, (stage_num_ps + 4'd1) );
						game_ns = game_states_e'( (stage_num_ps + 4'd1) );
						change_stage_ns = 1'b0;
					end
				else if ( ballhole_collide[(`NUM_BALLS):1] != {(`NUM_BALLS){1'b0}} ) // scored!
					begin
						if ( stage_num_ps == 4'd1 || stage_num_ps == 4'd2 )
							begin
								game_ns = s_scored;
								//stage_num_ns = (stage_num_ps + 4'd1);
							end
						else //if ( stage_num_ps == 4'd2 )
							begin
								if ( curr_Hole_id == request_hole )
									begin
										game_ns = s_scored;
									end
								else
									begin
										game_ns = s_missed;
									end
							end
					end
				else if ( balls_in_game[(`NUM_BALLS):1] == {(`NUM_BALLS){1'b0}} && balls_in_game[0] == 1'b1 && !wonFlag_ps ) // if only white stayed in game
					begin
						game_ns = s_win;
						rst_cntN_ns = 1'b0;
					end
				else if ( ballhole_collide[0] == 1'b1 && !lostFlag_ps ) // white is out, lost
					begin
						game_ns = s_lose;
						rst_cntN_ns = 1'b0;
					end
					
				end // idle
			
			s_stage_1: begin
				/// make stage 1 setup ///
				
				stage_num_ns = 4'd1;
				//s_stage_ns = 4'd1;
				game_ns = s_idle;
			end // stage 1
			
			s_stage_2: begin
			/// make stage 2 setup ///
				
				stage_num_ns = 4'd2;
				//request_hole_ns = 3'd3;
				game_ns = s_idle;
			end // stage 2
			
			
			s_stage_3: begin
			/// make stage 3 setup ///
				
				stage_num_ns = 4'd3;
				request_hole_ns = 3'd2;
				game_ns = s_idle;
			end // stage 3
			
			s_stage_4: begin
			/// make stage 4 setup ///
				
				stage_num_ns = 4'd4;
				request_hole_ns = 3'd5;
				game_ns = s_idle;
			end // stage 4
			
			s_stage_5: begin
			/// make stage 5 setup ///
				
				stage_num_ns = 4'd5;
				request_hole_ns = 3'd6;
				game_ns = s_idle;
			end // stage 5
			
			s_stage_6: begin
			/// make stage 6 setup ///
				
				stage_num_ns = 4'd6;
				request_hole_ns = 3'd3;
				game_ns = s_idle;
			end // stage 6 
				
			s_win: begin
			
				if ( winPulse_ps != 1'b1 )		
					begin	
						rst_cntN_ns = 1'b1; // turn reset off
						timeLoadN_ns = 1'b0; // load
						seconds_to_load = 4'd2; // load two seconds
						winPulse_ns = 1'b1; 
						wonFlag_ns = 1'b1;
					end
				
				else if ( finished_counting == 1'b1 ) 
					begin
						winPulse_ns = 1'b0; 
						//stage_num_ns = stage_num_ps + 4'd1;
						
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
						lostFlag_ns = 1'b1;
					end
				
				else if ( finished_counting == 1'b1 ) 
					begin
						losePulse_ns = 1'b0;
						game_ns = s_idle;
					end
					
				end	// lose
			
			
			s_scored: begin
				scoreHighLoad_ns = scoreHighLoad_ps + 4'd1;
				scoreLowLoad_ns = scoreLowLoad_ps;
				scoreLoadN_ns = 1'b0;
				scoredPulse_ns = 1'b1;
				//score_up_ns = 1'b1;
				if ( `FINAL_STAGE > stage_num_ps ) //// TODO: need to move to score!
					begin
						change_stage_ns = 1'b1;
					end
				game_ns = s_idle;
				end // scored
				
			s_missed: begin
				scoreLoadN_ns = 1'b0;

				if ( scoreLowLoad_ps >= 4'd5)
					begin	
						scoreHighLoad_ns = scoreHighLoad_ps;
						scoreLowLoad_ns = scoreLowLoad_ps - 4'd5;
					end
				else 
					begin	
						if ( scoreHighLoad_ps >= 4'd1 )
							begin
								scoreHighLoad_ns = scoreHighLoad_ps - 4'd1;
								scoreLowLoad_ns = 4'd10 - ( 4'd5 - scoreLowLoad_ps );
							end
						else 
							begin
								scoreHighLoad_ns = 4'd0;
								scoreLowLoad_ns = 4'd0;
							end
					end
					
				game_ns = s_idle;
					
			end // missed
						
		endcase
		
	end // always comb
	
endmodule
