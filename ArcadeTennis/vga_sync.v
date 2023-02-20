// Module to Initialise the VGA Display. 

module vga_sync(

// Declaring the input and output variables.
	input clk,reset,
	output hsync,vsync, video_on,p_tick,
	output [9:0] x,y
	);


	
	// Declearing local parameters
	localparam V_DISPLAY       = 480; 
	localparam V_T_BORDER      =  10;
	localparam V_B_BORDER      =  33; 
	localparam V_RETRACE       =   2; 
	localparam V_MAX           = V_DISPLAY + V_T_BORDER + V_B_BORDER + V_RETRACE - 1;
   localparam START_V_RETRACE = V_DISPLAY + V_B_BORDER;
	localparam END_V_RETRACE   = V_DISPLAY + V_B_BORDER + V_RETRACE - 1;
	localparam H_DISPLAY       = 640; 
	localparam H_L_BORDER      =  48; 
	localparam H_R_BORDER      =  16; 
	localparam H_RETRACE       =  96; 
	localparam H_MAX           = H_DISPLAY + H_L_BORDER + H_R_BORDER + H_RETRACE - 1;
	localparam START_H_RETRACE = H_DISPLAY + H_R_BORDER;
	localparam END_H_RETRACE   = H_DISPLAY + H_R_BORDER + H_RETRACE - 1;
	
	
	
	// Initialising the Clock with 25MHz
	reg pixel_reg;
	wire pixel_next;
	wire pixel_tick;
	
	always @(posedge clk, posedge reset)
		if(reset)
		  pixel_reg <= 0;
		else
		  pixel_reg <= pixel_next;
	
	assign pixel_next = pixel_reg + 1; 
	
	assign pixel_tick = (pixel_reg == 0); 
	
	
	reg [9:0] h_count_reg, h_count_next, v_count_reg, v_count_next;
	
	
	reg vsync_reg, hsync_reg;
	wire vsync_next, hsync_next;
 
	
	always @(posedge clk, posedge reset)
		if(reset)
			begin
           		v_count_reg <= 0;
            		h_count_reg <= 0;
            		vsync_reg   <= 0;
            		hsync_reg   <= 0;
			end
		else
			begin
            		v_count_reg <= v_count_next;
            		h_count_reg <= h_count_next;
            		vsync_reg   <= vsync_next;
            		hsync_reg   <= hsync_next;
			end
			
	always @*
		begin
		h_count_next = pixel_tick ? 
		               h_count_reg == H_MAX ? 0 : h_count_reg + 1
			       : h_count_reg;
		
		v_count_next = pixel_tick && h_count_reg == H_MAX ? 
		               (v_count_reg == V_MAX ? 0 : v_count_reg + 1) 
			       : v_count_reg;
		end
		
   
   // Horizontal Path
   assign hsync_next = h_count_reg >= START_H_RETRACE && h_count_reg <= END_H_RETRACE;
   
   // Vertical Path
   assign vsync_next = v_count_reg >= START_V_RETRACE && v_count_reg <= END_V_RETRACE;

   // Displaying the Path
   assign video_on = (h_count_reg < H_DISPLAY) && (v_count_reg < V_DISPLAY);

   // Declaring the output variables
   assign hsync  = hsync_reg;
   assign vsync  = vsync_reg;
   assign x      = h_count_reg;
   assign y      = v_count_reg;
   assign p_tick = pixel_tick;


	
	
endmodule
// Ending the module
