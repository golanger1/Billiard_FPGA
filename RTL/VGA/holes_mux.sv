
// (c) Technion IIT, Department of Electrical Engineering 2021 
//-- Alex Grinshpun Apr 2017
//-- Dudy Nov 13 2017
// SystemVerilog version Alex Grinshpun May 2018
// coding convention dudy December 2018

//-- Eyal Lev 31 Jan 2021

module	holes_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,

		  // holes
					input		logic Graphic_Hole_1_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_1_RGB,
					input		logic Hit_Hole_1_DrawingRequest,
					input		logic	[7:0] Hit_Hole_1_RGB,
					input		logic Graphic_Hole_2_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_2_RGB,
					input		logic Hit_Hole_2_DrawingRequest,
					input		logic	[7:0] Hit_Hole_2_RGB,
					input		logic Graphic_Hole_3_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_3_RGB,
					input		logic Hit_Hole_3_DrawingRequest,
					input		logic	[7:0] Hit_Hole_3_RGB,
					input		logic Graphic_Hole_4_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_4_RGB,
					input		logic Hit_Hole_4_DrawingRequest,
					input		logic	[7:0] Hit_Hole_4_RGB,
					input		logic Graphic_Hole_5_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_5_RGB,
					input		logic Hit_Hole_5_DrawingRequest,
					input		logic	[7:0] Hit_Hole_5_RGB,
					input		logic Graphic_Hole_6_DrawingRequest,
					input		logic	[7:0] Graphic_Hole_6_RGB,
					input		logic Hit_Hole_6_DrawingRequest,
					input		logic	[7:0] Hit_Hole_6_RGB,
			  
					
					output	logic	[2:0] Hole_ID,
					output	logic Graphic_Hole_DR,
					output	logic	[7:0] RGBOut,
					output	logic Hit_Hole_DR
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut			 <= 8'b0;
			Hit_Hole_DR 	 <= 1'b0;
			Graphic_Hole_DR <= 1'b0;
	end
	
	else begin
		Graphic_Hole_DR <= 1'b0;
		Hit_Hole_DR <= 1'b0;
	
		if ( Graphic_Hole_1_DrawingRequest == 1'b1 )		 begin
			Hole_ID = 3'd1;
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_1_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_1_RGB;
			else begin
				RGBOut <= Hit_Hole_1_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		 
		else if ( Graphic_Hole_2_DrawingRequest == 1'b1 )    begin
			Hole_ID = 3'd2; 
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_2_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_2_RGB;
			else begin
				RGBOut <= Hit_Hole_2_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		
		else if ( Graphic_Hole_3_DrawingRequest == 1'b1 )    begin
			Hole_ID = 3'd3;
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_3_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_3_RGB;
			else begin
				RGBOut <= Hit_Hole_3_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		
		else if ( Graphic_Hole_4_DrawingRequest == 1'b1 )    begin
			Hole_ID = 3'd4;
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_4_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_4_RGB;
			else begin
				RGBOut <= Hit_Hole_4_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		
		else if ( Graphic_Hole_5_DrawingRequest == 1'b1 )    begin
			Hole_ID = 3'd5;
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_5_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_5_RGB;
			else begin
				RGBOut <= Hit_Hole_5_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		
		else if ( Graphic_Hole_6_DrawingRequest == 1'b1 )    begin
			Hole_ID = 3'd6;
			Graphic_Hole_DR <= 1'b1;
			if ( Hit_Hole_6_DrawingRequest == 1'b0 )
				RGBOut <= Graphic_Hole_6_RGB;
			else begin
				RGBOut <= Hit_Hole_6_RGB;
				Hit_Hole_DR <= 1'b1;
				end
			end
		
		
	end ; 
end

endmodule


