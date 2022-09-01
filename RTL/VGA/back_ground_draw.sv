//-- feb 2021 add all colors square 
// (c) Technion IIT, Department of Electrical Engineering 2021


module	back_ground_draw	(	

					input	logic	clk,
					input	logic	resetN,
					input 	logic	[10:0]	pixelX,
					input 	logic	[10:0]	pixelY,

					output	logic	[7:0]	BG_RGB,
					output	logic	[1:0]	bordersDrawReq 
);

const int	xFrameSize	=	639;
const int	yFrameSize	=	479;
const int	bracketOffset = 30;

logic [2:0] redBits;
logic [2:0] greenBits;
logic [1:0] blueBits;


localparam logic [2:0] DARK_COLOR = 3'b111 ;// bitmap of a dark color
localparam logic [2:0] LIGHT_COLOR = 3'b000 ;// bitmap of a light color
 

// this is a block to generate the background 
 
 
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
				redBits <= DARK_COLOR ;	
				greenBits <= DARK_COLOR  ;	
				blueBits <= DARK_COLOR ;	 
	end 
	else begin

	// defaults, green background and no draw request.
		greenBits <= 3'b110 ; 
		redBits <= 3'b010 ;
		blueBits <= 2'b00;
		bordersDrawReq <= 	2'b00 ; 

					
	/*
		// draw the black borders of the screen
		if (pixelX == 0 || pixelY == 0  || pixelX == xFrameSize || pixelY == yFrameSize)
			begin 
				redBits 	 <= LIGHT_COLOR ;	
				greenBits <= LIGHT_COLOR ;	
				blueBits  <= LIGHT_COLOR ;	// 3rd bit will be truncated
			end*/
		// draw  four lines with "bracketOffset" offset from the border 
		
		// draw the black borders, send bordersDrawReq.
		if (        pixelX == bracketOffset ||
						pixelX == (xFrameSize-bracketOffset) ) 
			begin 
			/*
					redBits 	 <= 3'b011 ;	
					greenBits <= 3'b001 ;	
					blueBits  <= 2'b01  ;
					*/
					redBits 	 <= LIGHT_COLOR ;	
					greenBits <= LIGHT_COLOR ;	
					blueBits  <= LIGHT_COLOR ;
					
					bordersDrawReq[0] <= 	1'b1 ; // pulse if drawing the boarders 
			end

		if (        pixelY == bracketOffset ||
						pixelY == (yFrameSize-bracketOffset) ) 
			begin 
			/*
					redBits 	 <= 3'b011 ;	
					greenBits <= 3'b001 ;	
					blueBits  <= 2'b01  ;
					*/
					redBits 	 <= LIGHT_COLOR ;	
					greenBits <= LIGHT_COLOR ;	
					blueBits  <= LIGHT_COLOR ;
					
					bordersDrawReq[1] <= 	1'b1 ; // pulse if drawing the boarders 
			end
	
	// note numbers can be used inline if they appear only once 


	
	// draw brown borders 
	//-------------------------------------------------------------------------------------
		
		if ( ( (pixelX > 0) && (pixelX < bracketOffset) ) ||
		( (pixelX > (xFrameSize - bracketOffset)) && (pixelX < xFrameSize) ) ) 
				begin 
					redBits 	 <= 3'b011 ;	
					greenBits <= 3'b001 ;	
					blueBits  <= 2'b00  ; 
					bordersDrawReq[0] <= 	1'b1 ; // pulse if drawing the boarders 
				end
		
		if ( ( (pixelY > 0) && (pixelY < bracketOffset) ) ||
		( (pixelY > (yFrameSize - bracketOffset)) && (pixelY < yFrameSize) ) ) 
				begin 
					redBits 	 <= 3'b011 ;	
					greenBits <= 3'b001 ;	
					blueBits  <= 2'b00  ; 
					bordersDrawReq[1] <= 	1'b1 ; // pulse if drawing the boarders 
				end
						
		// draw the white borders of the screen
		if (pixelX == 0 || pixelY == 0  || pixelX == xFrameSize || pixelY == yFrameSize)
			begin 
				redBits 	 <= DARK_COLOR ;	
				greenBits <= DARK_COLOR ;	
				blueBits  <= DARK_COLOR ;	// 3rd bit will be truncated
			end


		
	BG_RGB =  {redBits , greenBits , blueBits} ; //collect color nibbles to an 8 bit word 
			


	end; 	
end 
endmodule

