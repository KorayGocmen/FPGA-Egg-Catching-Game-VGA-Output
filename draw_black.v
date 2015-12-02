//`include "background_ROM.v"

module draw_black (enable, clock, resetn, vga_x, vga_y, colour, done);
	input clock;
	input enable;
	input resetn;
	output [7:0] vga_x;
	output [6:0] vga_y;
	output reg done = 0;
	output [2:0] colour;
	
	
	wire [14:0] address;
	reg [7:0] count_x = 0;
	reg [6:0] count_y = 0;
	
	
	background_ROM back (
					.address(address),
					.clock(clock),
					.q(colour)
					);
	
	reg [7:0] addr_x = 0;
	reg [6:0] addr_y = 0;
	always @(posedge clock)
	begin
		if (~resetn)
		begin
			addr_x = 0;
			addr_y = 0;
			count_x = 0;
			count_y = 0;
		end
		else if (enable)
		begin
			done = 0;
			if (addr_x != 160)
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
				if (addr_y == 120)
				begin
					count_y = 0;
					addr_y = 0;
					done = 1;
				end
			end
		end
	end

	
	assign address = addr_x + 160*(addr_y);
	
	assign vga_x = count_x;
	assign vga_y = count_y;
	
endmodule
