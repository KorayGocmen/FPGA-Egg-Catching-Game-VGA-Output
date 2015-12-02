/*`include "vga_adapter/vga_adapter.v"
`include "vga_adapter/vga_controller.v"
`include "vga_adapter/vga_pll.v"
`include "vga_adapter/vga_address_translator.v"
`include "muxes/mux.v"
`include "draw egg/draw_egg.v"
`include "black/draw_black.v"
`include "animate egg/animate_egg.v"
`include "animate plyr/animate_plyr.v"
`include "draw_gameover.v" */

module EggCatcherTop (CLOCK_50, KEY, SW, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, LEDR, VGA_CLK, VGA_HS, VGA_VS, VGA_BLANK_N, VGA_SYNC_N, VGA_R, VGA_G,VGA_B);
	input CLOCK_50;				
	input [3:0] KEY;
	input [9:0] SW;
	output [6:0] HEX0;
	output [6:0] HEX1;
	output [6:0] HEX2;
	output [6:0] HEX3;
	output [6:0] HEX4;
	output [6:0] HEX5;
	output [9:0] LEDR;
	
	reg exit;
	output			VGA_CLK;   				
	output			VGA_HS;					
	output			VGA_VS;					
	output			VGA_BLANK_N;				
	output			VGA_SYNC_N;				
	output	[9:0]	VGA_R;   			
	output	[9:0]	VGA_G;	 			
	output	[9:0]	VGA_B;   			
	
	wire left, right;
	assign left = KEY[2];
	assign right = KEY[1];
	
	wire lose_egg1;
	wire lose_egg2;
	wire lose_egg3;
	
	wire resetn;
	wire clock;
	wire [2:0] colour;
	wire [7:0] x;
	wire [6:0] y;
	reg [2:0] item_selector;
	reg writeEn;
	
	assign clock = CLOCK_50;
	assign resetn = KEY[3];
	
	wire done_egg1;
	wire done_egg2;
	wire done_egg3;
	wire done_plyr;
	wire done_black;
	wire done_gameover;
	
	reg done_wait;
	
	reg go_egg1;
	reg go_egg2;
	reg go_egg3;
	reg go_plyr;
	reg go_black;
	reg go_gameover;
	reg go_wait;
	reg go_score;
	
	wire [7:0] x_egg1; // vga_x for egg1
	wire [7:0] x_egg2; // vga_x for egg2
	wire [7:0] x_egg3; //...
	wire [6:0] y_egg1;
	wire [6:0] y_egg2;
	wire [6:0] y_egg3;
	
	wire [7:0] x_plyr; // vga_x value for plyr
	wire [6:0] y_plyr; // vga_y value for plyr
	wire [2:0] colour_plyr;
	
	wire [7:0] x_black; // vga_x value for plyr
	wire [6:0] y_black; // vga_y value for plyr
	wire [2:0] colour_black;
	
	wire [7:0] x_gameover; // vga_x value for plyr
	wire [6:0] y_gameover; // vga_y value for plyr
	wire [2:0] colour_gameover;
	
	reg [7:0] start_egg1_x = 20;
	reg [7:0] start_egg2_x = 83;
	reg [7:0] start_egg3_x = 145;
	reg [6:0] start_egg1_y = 20;
	reg [6:0] start_egg2_y = 20;
	reg [6:0] start_egg3_y = 20;
	reg [7:0] start_plyr_x = 60;
	
	wire [7:0] out_egg1_x;
	wire [7:0] out_egg2_x;
	wire [7:0] out_egg3_x;
	wire [6:0] out_egg1_y;
	wire [6:0] out_egg2_y;
	wire [6:0] out_egg3_y;
	wire [7:0] out_plyr_x;
	
	wire [2:0] colour_1;
	wire [2:0] colour_2;
	wire [2:0] colour_3;
	
	wire [2:0] egg1_speed;
	wire [2:0] egg2_speed;
	wire [2:0] egg3_speed;
	
	assign egg1_speed = 3'b001;
	assign egg2_speed = 3'b011;
	assign egg3_speed = 3'b001;
	
	assign colour = colour_1;	
	assign  LEDR[6:0] = y_egg1;
	
	wire [17:0] vga_in;
	
	wire [7:0] sw_x_egg1;
	

	superMux vga_selector (
						.x_egg1(x_egg1),
						.x_egg2(x_egg2),
						.x_egg3(x_egg3), 
						.y_egg1(y_egg1),
						.y_egg2(y_egg2), 
						.y_egg3(y_egg3), 
						.colour_egg(colour), 
						.x_plyr(x_plyr), 
						.y_plyr(y_plyr), 
						.colour_plyr(colour_plyr), 
						.x_black(x_black), 
						.y_black(y_black), 
						.colour_black(colour_black), 
						.x_gameover(x_gameover), 
						.y_gameover(y_gameover), 
						.colour_gameover(colour_gameover), 
						.out(vga_in), 
						.MuxSelect(item_selector)
						);
	
	animate_plyr plyr3 (
						.go(go_plyr), 
						.resetn(resetn), 
						.vga_x(x_plyr), 
						.vga_y(y_plyr), 
						.in_x(start_plyr_x), 
						.out_x(out_plyr_x), 
						.colour(colour_plyr), 
						.done(done_plyr), 
						.clock(CLOCK_50), 
						.left(left), 
						.right(right)	
						);
						
	
	draw_gameover gameover (
					.enable(go_gameover),
					.clock(CLOCK_50),
					.resetn(resetn),
					.vga_x(x_gameover),
					.vga_y(y_gameover),
					.colour(colour_gameover),
					.done(done_gameover)
					);
	
	
	animate_egg egg1 (
					.go(go_egg1),
					.clock(CLOCK_50),
					.lose(lose_egg1),
					.resetn(resetn), 
					.vga_x(x_egg1), 
					.vga_y(y_egg1), 
					.in_x(start_egg1_x), 
					.in_y(start_egg1_y), 
					.out_y(out_egg1_y), 
					.colour(colour_1), 
					.plyr_x(x_plyr), 
					.done(done_egg1),
					.speed(egg1_speed)
					);
					
	animate_egg egg2 (
					.go(go_egg2),
					.clock(CLOCK_50),
					.lose(lose_egg2),
					.resetn(resetn), 
					.vga_x(x_egg2), 
					.vga_y(y_egg2), 
					.in_x(start_egg2_x), 
					.in_y(start_egg2_y),  
					.out_y(out_egg2_y), 
					.colour(colour_2), 
					.plyr_x(x_plyr), 
					.done(done_egg2),
					.speed(egg2_speed)
					);
					
	animate_egg egg3 (
					.go(go_egg3),
					.clock(CLOCK_50),
					.lose(lose_egg3),
					.resetn(resetn), 
					.vga_x(x_egg3), 
					.vga_y(y_egg3), 
					.in_x(start_egg3_x), 
					.in_y(start_egg3_y), 
					.out_y(out_egg3_y), 
					.colour(colour_3), 
					.plyr_x(x_plyr), 
					.done(done_egg3),
					.speed(egg3_speed)
					);
					
	draw_black black (
					.enable(go_black),
					.clock(CLOCK_50),
					.resetn(resetn),
					.vga_x(x_black),
					.vga_y(y_black),
					.colour(colour_black),
					.done(done_black)
					);
		
	///////////////////////////////////////
	/////////////	SCORE	///////////////
	///////////////////////////////////////
	reg [27:0] score_count = 27'b0;
	reg [27:0] score = 27'b0;
	wire [27:0] w_score;
	always @(posedge clock)
	begin
		if (go_score)
		begin
			score_count = score_count + 1'b1;
			if (score_count == 49999999)
			begin
				score = score + 1'b1;
				score_count = 27'b0;
			end
		end
		else
			score = 27'b0;
	end
	assign w_score = score;
	hex_decoder hex0 (
					.data(w_score[6:0]),
					.segments(HEX0)
					);
	hex_decoder hex1 (
					.data(w_score[13:7]),
					.segments(HEX1)
					);
	hex_decoder hex2 (
					.data(w_score[20:14]),
					.segments(HEX2)
					);
	hex_decoder hex3 (
					.data(w_score[27:21]),
					.segments(HEX3)
					);
	hex_decoder hex4 (
					.data(7'b0),
					.segments(HEX4)
					);
	hex_decoder hex5 (
					.data(7'b0),
					.segments(HEX5)
					);
	
	//////////////////////////////////////////
	////////	ANIMATION SPEED		//////////
	/////////////////////////////////////////
	
	reg [27:0] count_wait = 27'b0;	
	always @(posedge clock)
	begin
		if (go_wait)
		begin
			count_wait = count_wait + 1'b1;
			done_wait = 0;

			if (count_wait == 4999999)
			begin
				count_wait = 27'b0;
				done_wait = 1;
			end
		end
	end
	
	////////////////////////////////////////
	////////	MAIN GAME FSM 	///////////
	///////////////////////////////////////
	wire start;
	assign start = KEY[0];
	parameter [3:0] MENU = 3'b000, PRINT_EGG1 = 3'b001, PRINT_EGG2 = 3'b010, PRINT_EGG3 = 3'b100,
					PRINT_PLYR = 3'b011, PRINT_BLACK = 3'b101, EXIT = 3'b110,  WAIT = 3'b111;
	reg [3:0] PresentState, NextState;
	
	always @(*)
	begin : StateTable
		case (PresentState)
		MENU:
		begin
			if (start == 1)
				NextState = MENU;
			else
				NextState = PRINT_BLACK;
		end
		PRINT_EGG1:
		begin
			if (lose_egg1)
			begin
				NextState = EXIT;
			end
			else
			begin
				if (done_egg1)
					NextState = PRINT_EGG2;
				else
					NextState = PRINT_EGG1;
			end
		end
		PRINT_EGG2:
		begin
			if (lose_egg2)
			begin
				NextState = EXIT;
			end
			else
			begin
				if (done_egg2)
					NextState = PRINT_EGG3;
				else
					NextState = PRINT_EGG2;
			end
		end
		PRINT_EGG3:
		begin
			if (lose_egg3)
			begin
				NextState = EXIT;
			end
			else
			begin
				if (done_egg3)
					NextState = PRINT_PLYR;
				else
					NextState = PRINT_EGG3;
			end
		end
		PRINT_PLYR:
		begin
			if (done_plyr)
				NextState = WAIT;
			else
				NextState = PRINT_PLYR;
		end
		PRINT_BLACK:
		begin
			if (done_black)
				NextState = PRINT_EGG1;
			else
				NextState = PRINT_BLACK;
		end
		EXIT:
		begin
			if (start == 1)
				NextState = EXIT;
			else
				NextState = MENU;
		end
		WAIT:
		begin
			if (done_wait)
				NextState = PRINT_BLACK;
			else
				NextState = WAIT;
		end
		default: NextState = MENU;
		endcase
	end
	
	always @(*)
	begin: output_logic
		case (PresentState)
			MENU:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 0;
				go_score = 0;
				exit = 0;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b000;
			end
			PRINT_EGG1:
			begin
				go_wait = 0;
				go_egg1 = 1;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 1;
				go_score = 1;
				exit = 0;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b000;
			end
			PRINT_EGG2:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 1;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 1;
				go_score = 1;
				exit = 0;
				start_egg2_y = out_egg2_y;
				start_egg1_y = out_egg1_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b001;
			end
			PRINT_EGG3:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 1;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 1;
				go_score = 1;
				exit = 0;
				start_egg3_y = out_egg3_y;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b010;
			end
			PRINT_PLYR:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 1;
				go_black = 0;
				go_gameover = 0;
				writeEn = 1;
				go_score = 1;
				exit = 0;
				start_plyr_x = out_plyr_x;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				item_selector = 3'b100;
			end
			PRINT_BLACK:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 1;
				go_gameover = 0;
				writeEn = 1;
				go_score = 1;
				exit = 0;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b011;
			end
			EXIT:
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 1;
				writeEn = 1;
				go_score = 0;
				exit = 1;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b110;
			end
			WAIT:
			begin
				go_wait = 1;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 0;
				go_score = 1;
				exit = 0;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b000;
			end
			default: 
			begin
				go_wait = 0;
				go_egg1 = 0;
				go_egg2 = 0;
				go_egg3 = 0;
				go_plyr = 0;
				go_black = 0;
				go_gameover = 0;
				writeEn = 0;
				go_score = 0;
				exit = 0;
				start_egg1_y = out_egg1_y;
				start_egg2_y = out_egg2_y;
				start_egg3_y = out_egg3_y;
				start_plyr_x = out_plyr_x;
				item_selector = 3'b000;
			end
		endcase
	end
	
	always @(posedge clock)
	begin: state_FFs
		if(resetn == 1'b0)
			PresentState <= MENU;
		else
			PresentState <= NextState;
	end

	
	vga_adapter VGA(
			.resetn(resetn),
			.clock(CLOCK_50),
			.colour(vga_in[2:0]),
			.x(vga_in[17:10]),
			.y(vga_in[9:3]),
			.plot(writeEn), 
			.VGA_R(VGA_R),
			.VGA_G(VGA_G),
			.VGA_B(VGA_B),
			.VGA_HS(VGA_HS),
			.VGA_VS(VGA_VS),
			.VGA_BLANK(VGA_BLANK_N),
			.VGA_SYNC(VGA_SYNC_N),
			.VGA_CLK(VGA_CLK));
		defparam VGA.RESOLUTION = "160x120";
		defparam VGA.MONOCHROME = "FALSE";
		defparam VGA.BITS_PER_COLOUR_CHANNEL = 1;
		defparam VGA.BACKGROUND_IMAGE = "background.mif";
endmodule

module hex_decoder(data, segments);
	input [3:0] data;
	output [6:0] segments;
	reg [6:0] segments;

	parameter BLANK = 7'b111_1111; 
	parameter ZERO = 7'b100_0000; 
	parameter ONE = 7'b111_1001; 
	parameter TWO = 7'b010_0100; 
	parameter THREE = 7'b011_0000; 
	parameter FOUR = 7'b001_1001; 
	parameter FIVE = 7'b001_0010; 
	parameter SIX = 7'b000_0010; 
	parameter SEVEN = 7'b111_1000; 
	parameter EIGHT = 7'b000_0000; 
	parameter NINE = 7'b001_0000; 
	parameter A = 7'b000_1000;
	parameter B = 7'b000_0011;
	parameter C = 7'b100_0110;
	parameter D = 7'b010_0001;
	parameter E = 7'b000_0110;
	parameter F = 7'b000_1110;
	always @(*)
	begin
		case (data)
			4'b0000: segments <= ZERO;
			4'b0001: segments <= ONE;
			4'b0010: segments <= TWO;
			4'b0011: segments <= THREE;
			4'b0100: segments <= FOUR;
			4'b0101: segments <= FIVE;
			4'b0110: segments <= SIX;
			4'b0111: segments <= SEVEN;
			4'b1000: segments <= EIGHT;
			4'b1001: segments <= NINE;
			4'b1010: segments <= A;
			4'b1011: segments <= B;
			4'b1100: segments <= C;
			4'b1101: segments <= D;
			4'b1110: segments <= E;
			4'b1111: segments <= F;
			default: segments <= BLANK;
		endcase
	end
endmodule
