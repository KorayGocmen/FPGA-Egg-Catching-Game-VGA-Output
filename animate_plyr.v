//`include "draw plyr/draw_plyr.v"

//*****************************************ANIMATE PLYR FSM**********************************

module animate_plyr (go, resetn, vga_x, vga_y, in_x, out_x, colour, done, clock, left, right);	
	input go;
	input resetn;
	input clock;
	input left;
	input right;
	reg writeEn;
	reg go_increment;
	reg go_decrement;
	reg go_increment_init;

	parameter [2:0] WAIT = 3'b000, SHIFT = 3'b010, PRINT = 3'b110;
	parameter [6:0] HEIGHT_SCREEN = 7'b1111000;
	parameter [3:0] HEIGHT_EGG = 4'b1010, WIDTH_EGG = 4'b1010;
	parameter [4:0] HEIGHT_PLYR = 5'b10100, WIDTH_PLYR = 5'b10100;
		
	wire [7:0] w_out_x;
	wire [6:0] w_out_y;
	assign w_out_y = HEIGHT_SCREEN - HEIGHT_PLYR;
	wire done_print; //done signal to know when finished printing
	
	input [7:0] in_x; //original start x
	reg [7:0] w_in_x;
	
	wire [7:0] w_vga_x; 
	wire [6:0] w_vga_y;
	
	output [7:0] vga_x; //all pixels to be printed x
	output [6:0] vga_y; //all pixels to be printed y
	output [7:0] out_x; //new shifted start x
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
				NextState = WAIT;
			else
			begin
				NextState = SHIFT;
			end
		end
		SHIFT:
		begin
			NextState = PRINT;
			done = 0;
		end
		PRINT:
		begin
			if (done_print == 1)
			begin
				NextState = WAIT;
				done = 1;
			end
			else
			begin
				NextState = PRINT;
				done = 0;
			end
		end
		default: 
		begin 
			NextState = WAIT;
			done = 0;
		end
		endcase
	end
	
	always @(posedge clock)
	begin
		if (go_increment_init)
		begin
			w_in_x = in_x;
		end 
		else if (go_increment)
			w_in_x = w_in_x + 3'b111;
		else if (go_decrement)
			w_in_x = w_in_x - 3'b111;
	end
	
	always @(*)
	begin: output_logic
		case (PresentState)
			WAIT:
				begin
					go_increment_init = 1;
					go_increment = 0;
					go_decrement = 0;
					writeEn = 0;
				end
			SHIFT:
				begin
					go_increment_init = 0;
					if (left == 0)
					begin
						go_decrement = 1;
						go_increment = 0;
					end
					else if (right == 0)
					begin
						go_increment = 1;
						go_decrement = 0;
					end
					else
					begin
						go_increment = 0;
						go_decrement = 0;
					end
					writeEn = 0;
				end
			PRINT:
				begin
					writeEn = 1;
					go_increment_init = 0;
					go_increment = 0;
					go_decrement = 0;
				end
			default:
				begin
					writeEn = 0;
					go_increment_init = 0;
					go_increment = 0;
					go_decrement = 0;
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
	

	assign out_x = w_in_x;
	assign w_out_x = w_in_x;
	
	assign vga_x = w_vga_x;
	assign vga_y = w_vga_y;
	
	draw_plyr plyr1 (
					.reset(resetn),
					.writeEn(writeEn),
					.x(w_vga_x),
					.y(w_vga_y),
					.startx(w_out_x),
					.starty(w_out_y),
					.clock(clock),
					.color(colour),
					.done_print(done_print) 
					);
endmodule
