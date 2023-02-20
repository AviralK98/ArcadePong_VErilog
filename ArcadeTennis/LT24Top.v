// Initialising the LT24-LCD
module LT24Top (
    
    input clock,
    
    input globalReset,
    
    output resetApp,
    
    // Configuring the Interface. 
    output  LT24Wr_n,
    output  LT24Rd_n,
    output  LT24CS_n,
    output  LT24RS,
    output  LT24Reset_n,
    output [15:0] LT24Data,
    output  LT24LCDOn
);


reg  [ 7:0] xAddr;
reg  [ 8:0] yAddr;
reg  [15:0] pixelData;
wire        pixelReady;
reg         pixelWrite;
localparam LCD_WIDTH  = 240;
localparam LCD_HEIGHT = 320;

LT24Display #(
    .WIDTH       (LCD_WIDTH  ),
    .HEIGHT      (LCD_HEIGHT ),
    .CLOCK_FREQ  (50000000   )
) Display (
    
    .clock       (clock      ),
    .globalReset (globalReset),
    
    .resetApp    (resetApp   ),
    
    .xAddr       (xAddr      ),
    .yAddr       (yAddr      ),
    .pixelData   (pixelData  ),
    .pixelWrite  (pixelWrite ),
    .pixelReady  (pixelReady ),
    
    .pixelRawMode(1'b0       ),
    
    .cmdData     (8'b0       ),
    .cmdWrite    (1'b0       ),
    .cmdDone     (1'b0       ),
    .cmdReady    (           ),
    
    .LT24Wr_n    (LT24Wr_n   ),
    .LT24Rd_n    (LT24Rd_n   ),
    .LT24CS_n    (LT24CS_n   ),
    .LT24RS      (LT24RS     ),
    .LT24Reset_n (LT24Reset_n),
    .LT24Data    (LT24Data   ),
    .LT24LCDOn   (LT24LCDOn  )
);

wire [7:0] xCount;
UpCounterNbit #(
    .WIDTH    (          8),
    .MAX_VALUE(LCD_WIDTH-1)
) xCounter (
    .clock     (clock     ),
    .reset     (resetApp  ),
    .enable    (pixelReady),
    .countValue(xCount    )
);




// Initialising the Clock
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelWrite <= 1'b0;
    end else begin
    pixelWrite <= 1'b1;
        
    end
end
always @ (posedge clock or posedge resetApp) begin
    if (resetApp) begin
        pixelData <= 16'b0;
        xAddr <= 8'b0;
        yAddr <= 9'b0;
    end else if (pixelReady) begin
        xAddr  <= xCount;
        yAddr <= yCount;
        
        pixelData[15:11] <= xCount[7:3];
       
        pixelData[10: 5] <= yCount[8:3];
       
        if ((xCount == (LCD_WIDTH-1)) && (yCount == (LCD_HEIGHT-1))) begin
            pixelData[4:0]  <= pixelData[4:0] + 5'b1;
        end
    end
end

endmodule

// Module for initialising the number of the bits
module UpCounterNbit #(
    parameter WIDTH = 10,               
    parameter INCREMENT = 1,            
    parameter MAX_VALUE = (2**WIDTH)-1  
)(   
    input                    clock,
    input                    reset,
    input                    enable,    
    output reg [(WIDTH-1):0] countValue 
);

always @ (posedge clock) begin
    if (reset) begin
        
        countValue <= {(WIDTH){1'b0}};
    end else if (enable) begin
        
        if (countValue >= MAX_VALUE[WIDTH-1:0]) begin
            
            countValue <= {(WIDTH){1'b0}};   
        end else begin
            
            countValue <= countValue + INCREMENT[WIDTH-1:0];
        end
    end
end

endmodule



