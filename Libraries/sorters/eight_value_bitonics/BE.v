module BE #(
    parameter N = 7
) (
    input  signed [N-1:0] a,
    input  signed [N-1:0] b,
    output signed [N-1:0] min,
    output signed [N-1:0] max
);

    assign {min, max} = (a > b) ? {b, a} : {a, b};

endmodule
