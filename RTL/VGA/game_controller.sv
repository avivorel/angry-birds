
// game controller dudy Febriary 2020
// (c) Technion IIT, Department of Electrical Engineering 2021 
//updated --Eyal Lev 2021


module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_smiley,
			input	logic	drawing_request_boarders,
			
			
//---------------------#1-add input drawing request of box/number
			input	logic	drawing_request_number,

		
		

//---------------------#1-end input drawing request of box/number




//---------------------#2-add  drawing request of hart

			input	logic	drawing_request_hart,
			input	logic	drawing_request_wood_blocks,
			input	logic	drawing_request_pig,
			input	logic	pigs_left,

//---------------------#2-end drawing request of hart		

			
			output logic collision, // active in case of collision between two objects
			
			output logic SingleHitPulse, // critical code, generating A single pulse in a frame 
			
			

//---------------------#3-add collision  smiley and hart   -------------------------------------


			output logic collision_Smiley_Hart, // active in case of collision between Smiley and hart
			output logic collision_bird_woodBlock,
			output logic collision_bird_pig,

//---------------------#3-end collision  smiley and hart	--------------------------------------
			output logic	[3:0] current_level,
			output logic game_over

);

// drawing_request_smiley   -->  smiley
// drawing_request_boarders -->  brackets
// drawing_request_number   -->  number/box 

//assign collision = (drawing_request_smiley && drawing_request_boarders );// any collision --> comment after updating with #4 or #5 

//---------------------#4-update  collision  conditions - add collision between smiley and number   ----------------------------



//---------------------#4-end update  collision  conditions	 - add collision between smiley and number	-------------------------
	
					
						

//---------------------#5-update  collision  sconditions - add collision between smiley and hart  ---------------------------------

assign collision = collision_smiley_number || (drawing_request_boarders && drawing_request_smiley) || ( drawing_request_smiley && drawing_request_hart )||(collision_bird_woodBlock); 
	


//---------------------#5-end update  collision  conditions	- add collision between smiley and hart	-----------------------------
	



//-------------------------- #6-add colision between Smiley and hart-----------------

assign collision_Smiley_Hart = ( drawing_request_smiley && drawing_request_hart ) ;


//---------------------------#6-end colision betweenand Smiley and hart-----------------



logic flag ; // a semaphore to set the output only once per frame regardless of number of collisions 
logic collision_smiley_number; // collision between Smiley and number - is not output


//
logic num_of_levels = 4'd2;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag	<= 1'b0;
		SingleHitPulse <= 1'b0 ; 
		
	end 
	else begin 
	
//-------------------------- #7-add colision between Smiley and number-----------------

collision_smiley_number <= drawing_request_smiley && drawing_request_number;
collision_bird_woodBlock <= drawing_request_smiley && drawing_request_wood_blocks;
collision_bird_pig <= drawing_request_smiley && drawing_request_pig;

//-------------------------- #7-end colision between Smiley and number-----------------	
		
		
			SingleHitPulse <= 1'b0 ; // default 
			if(startOfFrame) 
				flag <= 1'b0 ; // reset for next time 
				
//	---#7 - change the condition below to collision between Smiley and number ---------

		if ( collision  && (flag == 1'b0)) begin 
			flag	<= 1'b1; // to enter only once 
			SingleHitPulse <= 1'b1 ; 
		end ; 
 
	end 
end

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		current_level <=4'd0;
		game_over <= 1'b0;
	end 
	else begin
		if(current_level >= num_of_levels)begin
			game_over <= 1'b1;
		end
		else if(pigs_left == 1'b0)begin
			current_level<=current_level+1;
		end
	end

end

endmodule
