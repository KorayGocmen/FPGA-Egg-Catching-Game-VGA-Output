//`include "draw egg/draw_egg.v"

//*****************************************ANIMATE EGG FSM**********************************

module animate_egg (go, lose, resetn, vga_x, vga_y, in_x, in_y, out_y, colour, plyr_x, done, clock, speed);	
	input go;
	input resetn;
	input clock;
	input [7:0] plyr_x;
	input [2:0] speed;
	output reg lose;
	reg writeEn;
	reg go_increment;
	reg go_increment_init;
	
	parameter [2:0] WAIT = 3'b000, SHIFT = 3'b010, CHECK = 3'b100, PRINT = 3'b110;
	parameter [6:0] HEIGHT_SCREEN = 7'b1111000;
	parameter [3:0] HEIGHT_EGG = 4'b0001, WIDTH_EGG = 4'b0001;
	parameter [4:0] HEIGHT_PLYR = 5'b10100, WIDTH_PLYR = 5'b10100;
		
	wire [6:0] w_out_y;
	wire done_print; //done signal to know when finished printing
	
	input [7:0] in_x; //original start x
	wire [7:0] w_in_x;
	assign w_in_x = in_x;
	input [6:0] in_y; //original start y
	reg [6:0] w_in_y;
	
	wire [7:0] w_vga_x; 
	wire [6:0] w_vga_y;
	
	output [7:0] vga_x; //all pixels to be printed x
	output [6:0] vga_y; //all pixels to be printed y
	output [6:0] out_y; //new shifted start y
	output [2:0] colour;
	output reg done = 0;
	
	reg [2:0] PresentState, NextState;
	reg [3:0] count;
	always @(*)
	begin : StateTable
		case (PresentState)
		WAIT:
		begin
			done = 0;
			if (go == 0)
			begin
				NextState = WAIT;
				lose = 0;
			end
			else
			begin
				NextState = SHIFT;
				lose = 0;
			end
		end
		SHIFT:
		begin
			NextState = CHECK;
			done = 0;
			lose = 0;
		end
		CHECK:
		begin
			if (((w_out_y >= (HEIGHT_SCREEN)) && ((w_in_x < plyr_x) || (w_in_x > (plyr_x + WIDTH_PLYR)))))
			begin
				NextState = WAIT;
				lose = 1;
				done = 0;
			end
			else
			begin
				NextState = PRINT;
				done = 0;
				lose = 0;
			end
		end
		PRINT:
		begin
			if (done_print == 1)
			begin
				NextState = WAIT;
				done = 1;
				lose = 0;
			end
			else
			begin
				NextState = PRINT;
				done = 0;
				lose = 0;
			end
		end
		default: 
		begin 
			NextState = WAIT;
			done = 0;
			lose = 0;
		end
		endcase
	end
	
	always @(posedge clock)
	begin
		if (go_increment_init)
		begin
			w_in_y = in_y;
		end
		if (go_increment)
		begin
			w_in_y = w_in_y + speed;
		end
	end
	
	always @(*)
	begin: output_logic
		case (PresentState)
			WAIT:
				begin
					go_increment_init = 1;
					go_increment = 0;
					writeEn = 0;
				end
			SHIFT:
				begin
					go_increment_init = 0;
					go_increment = 1;
					writeEn = 0;
				end
			CHECK:
				begin
					go_increment_init = 0;
					go_increment = 0;
					writeEn = 0;
				end
			PRINT:
				begin
					go_increment_init = 0;
					go_increment = 0;
					writeEn = 1;
				end
			default:
				begin
					go_increment_init = 0;
					go_increment = 0;
					writeEn = 0;
				end
		endcase
	end
	
	always @(posedge clock)
	begin: state_FFs
		if(resetn == 1'b0)
			PresentState <= WAIT;
		else
			PresentState <= NextState;
	end
	
	assign out_y = w_in_y;
	assign w_out_y = w_in_y;
	
	assign vga_x = w_vga_x;
	assign vga_y = w_vga_y;
	
	draw_egg egg1 (
					.reset(resetn),
					.writeEn(writeEn),
					.x(w_vga_x),
					.y(w_vga_y),
					.startx(w_in_x),
					.starty(w_out_y),
					.clock(clock),
					.color(colour),
					.done_print(done_print) 
					);
					
endmodule
