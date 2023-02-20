// Initialising the clock
module game_state(
	input clk, clk_1ms, reset,
	input [3:0] p1_score, p2_score,
	output reg [1:0] game_state
	);
	// Maximum score is 5
	reg [3:0] win = 4'b0101; 

	always @ (posedge clk)
	begin
		if (!reset)
			game_state = 0;
		else 
		begin
			if ( p1_score == win)
				game_state = 2'b10;
			else if ( p2_score == win)
				game_state = 2'b11;
			else 
				game_state = 2'b01;
		end
	end

endmodule
