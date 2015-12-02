module superMux (x_egg1, x_egg2, x_egg3, y_egg1, y_egg2, y_egg3, colour_egg, x_plyr, y_plyr, colour_plyr, x_black, y_black, colour_black, x_gameover, y_gameover, colour_gameover, out, MuxSelect);
	
	input [7:0] x_egg1, x_egg2, x_egg3, x_plyr, x_black, x_gameover;
	input [6:0] y_egg1, y_egg2, y_egg3, y_plyr, y_black, y_gameover; 
	input [2:0] colour_egg, colour_plyr, colour_black, colour_gameover;
	input [2:0] MuxSelect;
	
	output reg [17:0] out;
	
	always @(*)
	begin
		case (MuxSelect[2:0])
			3'b000: out = {x_egg1, y_egg1, colour_egg};
			3'b001: out = {x_egg2, y_egg2, colour_egg};
			3'b010: out = {x_egg3, y_egg3, colour_egg};
			3'b100: out = {x_plyr, y_plyr, colour_plyr};
			3'b011: out = {x_black, y_black, colour_black};
			3'b110: out = {x_gameover, y_gameover, colour_gameover};
			default: out = 0;
		endcase
	end
	
endmodule
