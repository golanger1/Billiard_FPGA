
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_Ball,
			input	logic	drawing_request_1,
			//input	logic	drawing_request_hole_1,
       // add input from box of numbers here 
			
			output logic collision, // active in case of collision between two objects
			//output logic disable_Ball1,
			output logic SingleHitPulse // critical code, generating A single pulse in a frame 
			
);

// drawing_request_Ball   -->  smiley
// drawing_request_1      -->  brackets
// drawing_request_2      -->  number/box 


assign collision = ( drawing_request_Ball &&  drawing_request_1 );// any collision ADD!!!
assign collision_BallWall = ( drawing_request_Ball &&  drawing_request_1 ); //now white&wall
//assign collision_BallHole = ( drawing_request_Ball &&  drawing_request_hole_1 );
//assign collision_BallBall = ( drawing_request_Ball &&  drawing_request_1 ); // not exist yet
						 						
						
// add colision between number and smiley definition and code as and where needed 


logic flag ; // a semaphore to set the output only once per frame / regardless of the number of collisions 

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		//disable_Ball1 = 1'b0;
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
	end 
	else begin 

		SingleHitPulse <= 1'b0 ; // default 
		if(startOfFrame) 
			flag <= 1'b0 ; // reset for next time 
				
//		change the section below  to collision between number and smiley


		if ( collision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		end ; 
		
		/*if ( collision_BallHole_1 && (flag == 1'b0) ) begin
			disable_Ball1 = 1'b1;
		end*/
	end 
end

endmodule
