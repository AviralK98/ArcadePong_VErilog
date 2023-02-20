// 
module clock_divider(
    input clk,
    output reg clk_1ms = 0
    );
    // Initialised to a 25MhZ
    reg [27:0] i = 0;
    
	 always @ (posedge clk)
    begin // for 1 ms
        if (i == 124999)
        begin
            i <= 0;
            clk_1ms = ~clk_1ms;
        end
        else i <= i+1;
    end
    
endmodule

