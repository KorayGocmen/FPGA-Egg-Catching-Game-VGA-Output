//`include "draw plyr/plyr_ROM.v"
module draw_plyr (x, y, startx, starty, color, clock, writeEn, reset, done_print);
	input clock;
	input writeEn;
	input reset;
	input [7:0] startx;
	input [6:0] starty;
	output [7:0] x;
	output [6:0] y;
	output reg done_print;
	output [2:0] color;
	
	wire [8:0] address;
	reg [7:0] count_x = 0;
	reg [6:0] count_y = 0;
	
	
	plyr_ROM plyr2 (
					.address(address),
					.clock(clock),
					.q(color)
					);
	
	reg [4:0] addr_x = 0;
	reg [4:0] addr_y = 0;
	always @(posedge clock)
	begin
		if (~reset)
		begin
			addr_x = 0;
			addr_y = 0;
			count_x = 0;
			count_y = 0;
		end
		else if (writeEn)
		begin
			done_print = 0;
			if (addr_x != 20)
			begin
				count_x = count_x + 1'b1;
				addr_x = addr_x + 1'b1;
			end
			else
			begin
				addr_y = addr_y + 1'b1;
				count_y = count_y + 1'b1;
				addr_x = 0;
				count_x = 0;
				if (addr_y == 20)
				begin
					count_y = 0;
					addr_y = 0;
					done_print = 1;
				end
			end
		end
	end

	
	assign address = addr_x + 20*(addr_y);
	assign x = count_x + startx;
	assign y = count_y + starty;
	
	
endmodule
