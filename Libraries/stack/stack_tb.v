`include "stack.v"
module LIFO_tb;

    // Parameters
    parameter DATA_WIDTH = 16;
    parameter STACK_DEPTH = 16;
    // Inputs
    reg clk;
    reg rst;
    reg wn;
    reg rn;
    reg [DATA_WIDTH-1:0] in;

    // Outputs
    wire [DATA_WIDTH-1:0] out;
    wire full;
    wire empty;

    // Instantiate the Unit Under Test (UUT)
    stack #(
        .DATA_WIDTH (DATA_WIDTH),
        .STACK_DEPTH(STACK_DEPTH)
    ) uut (
        .in(in),
        .full(full),
        .empty(empty),
        .clk(clk),
        .rst_n(rst),
        .wn(wn),
        .rn(rn),
        .out(out)
    );

    initial begin
        clk = 0;
        in  = 8'd3;
        rst = 1;
        clk = 1;
        #5;
        clk = 0;
        #5;
        rst = 0;

        #5;
        rst = 0;

        #5;
        rst = 1;
        $display("Start testing");
        wn  = 1;
        rn  = 0;
        in  = 8'd100;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd150;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd200;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd40;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd70;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd65;
        clk = 1;
        #5;
        clk = 0;
        #5;
        in  = 8'd15;
        clk = 1;
        #5;
        clk = 0;
        #5;

        wn  = 0;
        rn  = 1;
        clk = 1;
        #5;
        clk = 0;
        #5;

        clk = 1;
        #5;
        clk = 0;
        #5;
        $finish;
    end

endmodule
