// bitmap file 
// (c) Technion IIT, Department of Electrical Engineering 2021 
// generated bythe automatic Python tool 
 
 
 module crossBitMap (

					input	logic	clk, 
					input	logic	resetN, 
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY, 
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
 
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ; 
 
 
// generating the bitmap 
 

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hff ;// RGB value in the bitmap representing a transparent pixel  
logic[0:7][0:7][2:0] object_colors = {
	{2'b11,2'b11,2'b00,2'b00,2'b00,2'b00,2'b11,2'b11},
	{2'b11,2'b11,2'b00,2'b01,2'b01,2'b00,2'b11,2'b11},
	{2'b00,2'b00,2'b00,2'b01,2'b01,2'b00,2'b00,2'b00},
	{2'b00,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b00},
	{2'b00,2'b01,2'b01,2'b01,2'b01,2'b01,2'b01,2'b00},
	{2'b00,2'b00,2'b00,2'b01,2'b01,2'b00,2'b00,2'b00},
	{2'b11,2'b11,2'b00,2'b01,2'b01,2'b00,2'b11,2'b11},
	{2'b11,2'b11,2'b00,2'b00,2'b00,2'b00,2'b11,2'b11}};

 
 
 // pipeline (ff) to get the pixel color from the array 	 
//////////--------------------------------------------------------------------------------------------------------------= 
always_ff@(posedge clk or negedge resetN) 
begin 
	if(!resetN) begin 
		RGBout <=	8'h00; 
	end 
	else begin 
 
		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket
			if ( object_colors[offsetY][offsetX] == 2'b01 )
				begin
					RGBout <= 8'hC0; // RED
				end
			else if ( object_colors[offsetY][offsetX] == 2'b00 )
				begin
					RGBout <= 8'h00; // BLACK
				end
			else
				begin
					RGBout <= TRANSPARENT_ENCODING; // default
				end
		end  	 
		 
	end 
end 
 
//////////--------------------------------------------------------------------------------------------------------------= 
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != 2'b11 ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
 
endmodule 
