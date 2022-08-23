
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
		   // white ball 
					input		logic	WBallDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] WBallRGB, 
					     
		  // holes
					input		logic Hole_1_DrawingRequest,
					input		logic	[7:0] Hole_1_RGB,
					input		logic Hole_2_DrawingRequest,
					input		logic	[7:0] Hole_2_RGB,
			  
			  
		  ////////////////////////
		  // background 
					input    logic HartDrawingRequest, // box of numbers
					input		logic	[7:0] hartRGB,   
					input		logic	[7:0] backGroundRGB, 
			  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if ( WBallDrawingRequest == 1'b1 )   
			RGBOut <= WBallRGB;  //first priority 
		 
		 
		 else if ( Hole_2_DrawingRequest == 1'b1 )   
			RGBOut <= Hole_2_RGB;  //second priority
		 
		 else if ( Hole_1_DrawingRequest == 1'b1 )   
			RGBOut <= Hole_1_RGB;  //second priority
		 
		else if ( HartDrawingRequest == 1'b1)
			RGBOut <= hartRGB;
		else 
			RGBOut <= backGroundRGB ; // last priority 
		end ; 
	end

endmodule


