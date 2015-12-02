module draw_egg (x, y, startx, starty, color, clock, writeEn, reset, done_print);

	input clock;
	input writeEn;
	input reset;
	input [7:0] startx;
	input [6:0] starty;
	output [7:0] x;
	output [6:0] y;
	output done_print;
	output [2:0] color;
	
	assign x = startx + 8'b0;
	assign y = starty + 7'b0;
	assign color = 3'b000;
	assign done_print = 1;
	
endmodule
