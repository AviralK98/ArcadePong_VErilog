
`timescale 1 ns/100 ps

// Test bench module declaration
//  Always end test bench module names with _tb for clarity
//  There is no port list for a test bench
module LT24Top_tb;

//
// Parameter Declarations
//
localparam NUM_CYCLES = 1000;   //Run simulation for NUM_CYCLES clock cycles. (Max 1 billion)
localparam CLOCK_FREQ = 50000000; //Clock frequency

//
// Test Bench Generated Signals
//
reg  clock;
reg  reset;

//
// DUT Output Signals
//
wire resetApp;
// LT24 Display Interface
wire        LT24Wr_n;
wire        LT24Rd_n;
wire        LT24CS_n;
wire        LT24RS;
wire        LT24Reset_n;
wire [15:0] LT24Data;
wire        LT24LCDOn;

//
// Device Under Test
//
LT24Top  LT24Top_dut (
   .clock       ( clock       ),
   .globalReset ( reset       ),
   .resetApp    ( resetApp    ),
   
   .LT24Wr_n    ( LT24Wr_n    ),
   .LT24Rd_n    ( LT24Rd_n    ),
   .LT24CS_n    ( LT24CS_n    ),
   .LT24RS      ( LT24RS      ),
   .LT24Reset_n ( LT24Reset_n ),
   .LT24Data    ( LT24Data    ),
   .LT24LCDOn   ( LT24LCDOn   )
);

//
// Display Functional Model
//
LT24FunctionalModel #(
    .WIDTH  ( 240 ),
    .HEIGHT ( 320 )
) DisplayModel (
    // LT24 Interface
    .LT24Wr_n    ( LT24Wr_n    ),
    .LT24Rd_n    ( LT24Rd_n    ),
    .LT24CS_n    ( LT24CS_n    ),
    .LT24RS      ( LT24RS      ),
    .LT24Reset_n ( LT24Reset_n ),
    .LT24Data    ( LT24Data    ),
    .LT24LCDOn   ( LT24LCDOn   )
);

//
// Test Bench Logic
//

initial begin
    $display("%d ns\tSimulation Started",$time);       //Print to console that the simulation has started
    reset = 1'b1;                                      //Start in reset.
    repeat(2) @(posedge clock);                        //Wait for a couple of clock cycles
    reset = 1'b0;                                      //Then clear the reset signal.
    wait(resetApp === 1'b0);                           //Wait until the resetApp signal is zero.
    $display("%d ns\tInitialisation Complete",$time);  //Print to console that initialisation of the display is complete.
end


//
//Clock generator + simulation time limit.
//

initial begin
    clock = 1'b0; //Initialise the clock to zero.
end

//Next we convert our clock period to nanoseconds and half it
//to work out how long we must delay for each half clock cycle
real HALF_CLOCK_PERIOD = (1000000000.0 / $itor(CLOCK_FREQ)) / 2.0;

//Now generate the clock
integer half_cycles = 0;
always begin
    //Generate the next half cycle of clock
    #(HALF_CLOCK_PERIOD);          //Delay for half a clock period.
    clock = ~clock;                //Toggle the clock
    half_cycles = half_cycles + 1; //Increment the counter
    
    //Check if enough half clock cycle
    if (half_cycles == (2*NUM_CYCLES)) begin 
        //Once the number of cycles has been reached
		half_cycles = 0; 		   //Reset half cycles, so if we resume running with "run -all", we perform another chunk.
        $stop;                     //Break the simulation
        //Note: We can continue the simulation after this breakpoint using "run -continue" or "run x ns" or "run -all" in modelsim.
    end
end

endmodule
