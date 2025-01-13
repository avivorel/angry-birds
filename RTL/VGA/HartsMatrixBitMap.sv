// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	HartsMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic random_hart,
					
//------------------------input collision smiley and hart -student to complete functionality					
					input smiley_hart_collision,
			

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
 /*  end generated by the tool */


// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding 


logic [0:15] [0:15] [3:0]  MazeBitMapMask ;  

logic [0:15] [0:15] [3:0]  MazeDefaultBitMapMask= // defult table to load on reset 
{{64'h0001110000011100},
 {64'h0010002102100010},
 {64'h0010000010000010},
 {64'h0001000000000100},
 {64'h0001000000000100},
 {64'h0000100000001000},
 {64'h0000010000010000},
 {64'h0000001000100000},
 {64'h0000000101000000},
 {64'h0000000010000000},
 {64'h0000000000000000},
 {64'h0002000000002000},
 {64'h0000000000000000},
 {64'h0000000000000000},
 {64'h0000000000000000},
 {64'h0000000000000000}};


 

 logic [1:0] [0:31] [0:31] [7:0]  object_colors  = {
{
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h34,8'h34,8'h9d,8'h04,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h34,8'h34,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h78,8'h34,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h34,8'h34,8'h34,8'h79,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h34,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'h9d,8'h2c,8'h2c,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h2c,8'h2c,8'h2c,8'h9d,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'h2c,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h74,8'h74,8'h74,8'h74,8'h74,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF},
	{8'hFF,8'h9d,8'h9d,8'hff,8'hff,8'hff,8'h70,8'h9d,8'h9d,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h9d,8'h9d,8'h70,8'hff,8'hff,8'hff,8'h70,8'h9d,8'h9d,8'hFF,8'hFF},
	{8'hFF,8'h9d,8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h9d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'hff,8'hff,8'h00,8'h00,8'hff,8'hff,8'h74,8'hdc,8'hdc,8'h04,8'h04,8'h04,8'hdc,8'hdc,8'hdc,8'h04,8'h04,8'hdc,8'hdc,8'hdc,8'h74,8'hff,8'hff,8'hff,8'hff,8'h00,8'h00,8'hff,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h74,8'hdc,8'hdc,8'h04,8'h04,8'h04,8'hdc,8'hdc,8'h04,8'h04,8'h04,8'hdc,8'hdc,8'hdc,8'h74,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'hbc,8'hdc,8'hdc,8'h04,8'h04,8'h04,8'hdc,8'hdc,8'h04,8'h04,8'h04,8'hdc,8'hdc,8'hdc,8'h74,8'h70,8'hff,8'hff,8'hff,8'hff,8'hff,8'h70,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'h78,8'h70,8'hff,8'hff,8'hff,8'h70,8'h74,8'hdc,8'hdc,8'hdc,8'h04,8'hdc,8'hdc,8'hdc,8'hdc,8'h04,8'hbc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h70,8'hff,8'hff,8'hff,8'h70,8'h78,8'h9d,8'h9d,8'hFF},
	{8'hFF,8'h78,8'h78,8'h78,8'h70,8'h78,8'h78,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h9d,8'h9d,8'h9d,8'h78,8'h78,8'h78,8'h78,8'h9d,8'h9d,8'h78,8'hFF},
	{8'hFF,8'hFF,8'h9d,8'h9d,8'h78,8'h9d,8'h9d,8'h9d,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h74,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'hdc,8'h74,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h7c,8'h74,8'h74,8'h74,8'h74,8'h74,8'h74,8'h7c,8'h7c,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h7c,8'h7c,8'h7c,8'h7c,8'h7c,8'h7c,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h78,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h7c,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h78,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h78,8'h78,8'h78,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h9d,8'h78,8'h78,8'h78,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'h78,8'h78,8'h78,8'h78,8'h78,8'h78,8'h78,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF},
	{8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF,8'hFF}}
	,
{{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hD6, 8'h6D, 8'hB2, 8'hB6, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hB6, 8'h20, 8'h6D, 8'hB2, 8'h92, 8'h92, 8'h6D, 8'hDB, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'h84, 8'h60, 8'h85, 8'h8D, 8'h6D, 8'h92, 8'h69, 8'h89, 8'hFF, 8'hD2, 8'hD2, 8'hD2, 8'hB2, 8'hB2, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hD2, 8'hC0, 8'hE0, 8'hE0, 8'hC0, 8'hAD, 8'h69, 8'h49, 8'h85, 8'hA5, 8'hCD, 8'hD2, 8'hF2, 8'hF2, 8'hCD, 8'hAD, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hCD, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hA0, 8'h69, 8'hCD, 8'hA0, 8'hA9, 8'hAD, 8'hCD, 8'hCD, 8'hF2, 8'hCD, 8'hAD, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA9, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hCD, 8'hC4, 8'hC0, 8'hA0, 8'hA0, 8'hA5, 8'hA9, 8'h84, 8'hA4, 8'h80, 8'hD2, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hA9, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE5, 8'hE0, 8'hE0, 8'hC0, 8'hC0, 8'hA0, 8'hA0, 8'hA0, 8'h80, 8'hA0, 8'hA5, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hCD, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hC0, 8'hC0, 8'hA0, 8'hA0, 8'hFA, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hD2, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hE0, 8'hE0, 8'hC0, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hA4, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hE0, 8'hE0, 8'h80, 8'hB6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'h8D, 8'hA0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'h64, 8'hDA, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hD6, 8'h64, 8'hA0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'h80, 8'h89, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hCD, 8'h60, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'h80, 8'hB2, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hA4, 8'h60, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hA5, 8'hDB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hD6, 8'h80, 8'h80, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'hD6, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hED, 8'h80, 8'hA0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'hE0, 8'h60, 8'h92, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hF6, 8'hA9, 8'h60, 8'hC0, 8'hE0, 8'hE0, 8'hE0, 8'hC0, 8'h80, 8'h64, 8'h92, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFA, 8'hF6, 8'hD2, 8'h84, 8'h60, 8'hA0, 8'hC0, 8'h80, 8'h64, 8'h8D, 8'hDB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hF6, 8'hF6, 8'hD6, 8'h8D, 8'h40, 8'h60, 8'h85, 8'hAD, 8'hF6, 8'hFA, 8'hFB, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFA, 8'hF6, 8'hD6, 8'hD2, 8'hB2, 8'h89, 8'hCD, 8'hD2, 8'hD2, 8'hF2, 8'hF6, 8'hF6, 8'hFA, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFA, 8'hD6, 8'hD6, 8'hD2, 8'hD2, 8'hD2, 8'hCD, 8'hD2, 8'hD2, 8'hD2, 8'hD6, 8'hF6, 8'hF6, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFA, 8'hF6, 8'hF6, 8'hF6, 8'hF2, 8'hD2, 8'hD2, 8'hD2, 8'hD2, 8'hD2, 8'hD2, 8'hD6, 8'hF6, 8'hFA, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFA, 8'hF6, 8'hF6, 8'hF6, 8'hF6, 8'hD2, 8'hD2, 8'hD2, 8'hD2, 8'hD6, 8'hD6, 8'hF6, 8'hFA, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFA, 8'hFA, 8'hF6, 8'hF6, 8'hF6, 8'hF6, 8'hD6, 8'hD6, 8'hD6, 8'hD6, 8'hD6, 8'hF6, 8'hFA, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFA, 8'hFA, 8'hF6, 8'hF6, 8'hF6, 8'hF6, 8'hD6, 8'hD6, 8'hD6, 8'hF6, 8'hFA, 8'hFB, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFA, 8'hFA, 8'hFA, 8'hF6, 8'hF6, 8'hD6, 8'hFA, 8'hFA, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFA, 8'hFA, 8'hFA, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF },
{8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFB, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF, 8'hFF }
}};
 
// assign offsetY_LSB  = offsetY[4:0] ; // get lower 5 bits 
// assign offsetY_MSB  = offsetY[8:5] ; // get higher 4 bits 
// assign offsetX_LSB  = offsetX[4:0] ; 
// assign offsetX_MSB  = offsetX[8:5] ; 

// pipeline (ff) to get the pixel color from the array 	 

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		MazeBitMapMask  <=  MazeDefaultBitMapMask ;  //  copy default tabel 
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 
//----------------------------------add collision betwenn smiley and Hart -- disappear Hart  ------------------------------------------		
             if (smiley_hart_collision == 1'b1)
						MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= 4'h0;


		
//------------------------------------End collision betwenn smiley and Hart-------------------------------------------- 		
		
		if (InsideRectangle == 1'b1 )	
			begin 
		   	case (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]])
					 4'h0 : RGBout <= TRANSPARENT_ENCODING ;
					 4'h1 : RGBout <= object_colors[random_hart][offsetY[4:0]][offsetX[4:0]]; 
					 4'h2 : RGBout <= object_colors[2'h1][offsetY[4:0]][offsetX[4:0]] ; 
					 default:  RGBout <= TRANSPARENT_ENCODING ; 
				endcase
			end 
 
	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   
endmodule

