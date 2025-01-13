
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
		   // smiley 
					input		logic	smileyDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] smileyRGB, 
					     
		  // add the box here 
					input    logic boxDrawingRequest, // box of numbers **TEST
					input		logic	[7:0] boxRGB,
		  //add slingshot
		  			input    logic slingshotDrawingRequest, // box of numbers **TEST
					input		logic	[7:0] slingshotRGB,

		  
		  ////////////////////////
		  // background 
					input    logic HartDrawingRequest, // box of numbers
					input		logic	[7:0] hartRGB,   
					input		logic	[7:0] backGroundRGB, 
					input		logic	BGDrawingRequest, 
					input		logic	[7:0] RGB_MIF, 
			  //add wood
		
					input    logic woodDrawingRequest, // box of numbers **TEST
					input		logic	[7:0] woodRGB,
					
					input    logic pigDrawingRequest, // box of numbers **TEST
					input		logic	[7:0] pigRGB,
		  
		  
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
		if (smileyDrawingRequest == 1'b1 )   
			RGBOut <= smileyRGB;  //first priority 
		 
		 // add logic for box here 
		 
//--------------------------------------------------------------------------------------------		
		else if (pigDrawingRequest == 1'b1 )
			RGBOut <= pigRGB;
		else if (woodDrawingRequest == 1'b1 )
			RGBOut <= woodRGB;
		else if (boxDrawingRequest == 1'b1 )
			RGBOut <= boxRGB;

 		else if (HartDrawingRequest == 1'b1)
				RGBOut <= hartRGB;
				
		else if (HartDrawingRequest == 1'b1)
				RGBOut <= hartRGB;
				
				
		else if (slingshotDrawingRequest == 1'b1)
				RGBOut <= slingshotRGB;
		
		else RGBOut <= RGB_MIF ;// last priority 
		end ; 
	end

endmodule


