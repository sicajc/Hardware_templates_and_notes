module bitonic_sorter #(
    parameter N = 16
) (
    input rst_n,
    input clk,
    input signed [N-1:0] a,
    input signed [N-1:0] b,
    input signed [N-1:0] c,
    input signed [N-1:0] d,
    input signed [N-1:0] e,
    input signed [N-1:0] f,
    input signed [N-1:0] g,
    input signed [N-1:0] h,

    output signed [N-1:0] i,
    output signed [N-1:0] j,
    output signed [N-1:0] k,
    output signed [N-1:0] l,
    output signed [N-1:0] m,
    output signed [N-1:0] n,
    output signed [N-1:0] o,
    output signed [N-1:0] p
);

    reg signed  [N-1:0] bitonic_seq_reg[0:7];

    wire signed [N-1:0] lv1_1_min;
    wire signed [N-1:0] lv1_1_max;
    wire signed [N-1:0] lv1_2_min;
    wire signed [N-1:0] lv1_2_max;
    wire signed [N-1:0] lv1_3_min;
    wire signed [N-1:0] lv1_3_max;
    wire signed [N-1:0] lv1_4_min;
    wire signed [N-1:0] lv1_4_max;

    wire signed [N-1:0] lv2_1_min;
    wire signed [N-1:0] lv2_1_max;
    wire signed [N-1:0] lv2_2_min;
    wire signed [N-1:0] lv2_2_max;
    wire signed [N-1:0] lv2_3_min;
    wire signed [N-1:0] lv2_3_max;
    wire signed [N-1:0] lv2_4_min;
    wire signed [N-1:0] lv2_4_max;

    wire signed [N-1:0] lv3_1_min;
    wire signed [N-1:0] lv3_1_max;
    wire signed [N-1:0] lv3_2_min;
    wire signed [N-1:0] lv3_2_max;
    wire signed [N-1:0] lv3_3_min;
    wire signed [N-1:0] lv3_3_max;
    wire signed [N-1:0] lv3_4_min;
    wire signed [N-1:0] lv3_4_max;

    //Creating bitonic sequences
    BE #(
        .N(N)
    ) lv1_1 (
        .a  (a),
        .b  (b),
        .min(lv1_1_min),
        .max(lv1_1_max)
    );
    BE #(
        .N(N)
    ) lv1_2 (
        .a  (c),
        .b  (d),
        .min(lv1_2_min),
        .max(lv1_2_max)
    );
    BE #(
        .N(N)
    ) lv1_3 (
        .a  (e),
        .b  (f),
        .min(lv1_3_min),
        .max(lv1_3_max)
    );
    BE #(
        .N(N)
    ) lv1_4 (
        .a  (g),
        .b  (h),
        .min(lv1_4_min),
        .max(lv1_4_max)
    );

    BE #(
        .N(N)
    ) lv2_1 (
        .a  (lv1_1_min),
        .b  (lv1_2_max),
        .min(lv2_1_min),
        .max(lv2_1_max)
    );
    BE #(
        .N(N)
    ) lv2_2 (
        .a  (lv1_1_max),
        .b  (lv1_2_min),
        .min(lv2_2_min),
        .max(lv2_2_max)
    );
    BE #(
        .N(N)
    ) lv2_3 (
        .a  (lv1_3_min),
        .b  (lv1_4_max),
        .min(lv2_3_min),
        .max(lv2_3_max)
    );
    BE #(
        .N(N)
    ) lv2_4 (
        .a  (lv1_3_max),
        .b  (lv1_4_min),
        .min(lv2_4_min),
        .max(lv2_4_max)
    );

    BE #(
        .N(N)
    ) lv3_1 (
        .a  (lv2_1_min),
        .b  (lv2_2_min),
        .min(lv3_1_min),
        .max(lv3_1_max)
    );
    BE #(
        .N(N)
    ) lv3_2 (
        .a  (lv2_1_max),
        .b  (lv2_2_max),
        .min(lv3_2_min),
        .max(lv3_2_max)
    );
    BE #(
        .N(N)
    ) lv3_3 (
        .a  (lv2_3_max),
        .b  (lv2_4_max),
        .min(lv3_3_min),
        .max(lv3_3_max)
    );
    BE #(
        .N(N)
    ) lv3_4 (
        .a  (lv2_3_min),
        .b  (lv2_4_min),
        .min(lv3_4_min),
        .max(lv3_4_max)
    );

    always @(*) begin
        bitonic_seq_reg[0] = lv3_1_min;
        bitonic_seq_reg[1] = lv3_1_max;
        bitonic_seq_reg[2] = lv3_2_min;
        bitonic_seq_reg[3] = lv3_2_max;
        bitonic_seq_reg[4] = lv3_3_max;
        bitonic_seq_reg[5] = lv3_3_min;
        bitonic_seq_reg[6] = lv3_4_max;
        bitonic_seq_reg[7] = lv3_4_min;
    end

    //Bitonic sort process
    wire signed [N-1:0] sort_lv1_1_min;
    wire signed [N-1:0] sort_lv1_1_max;
    wire signed [N-1:0] sort_lv1_2_min;
    wire signed [N-1:0] sort_lv1_2_max;
    wire signed [N-1:0] sort_lv1_3_min;
    wire signed [N-1:0] sort_lv1_3_max;
    wire signed [N-1:0] sort_lv1_4_min;
    wire signed [N-1:0] sort_lv1_4_max;

    wire signed [N-1:0] sort_lv2_1_min;
    wire signed [N-1:0] sort_lv2_1_max;
    wire signed [N-1:0] sort_lv2_2_min;
    wire signed [N-1:0] sort_lv2_2_max;
    wire signed [N-1:0] sort_lv2_3_min;
    wire signed [N-1:0] sort_lv2_3_max;
    wire signed [N-1:0] sort_lv2_4_min;
    wire signed [N-1:0] sort_lv2_4_max;

    BE #(
        .N(N)
    ) sort_lv1_1 (
        .a  (bitonic_seq_reg[0]),
        .b  (bitonic_seq_reg[4]),
        .min(sort_lv1_1_min),
        .max(sort_lv1_1_max)
    );
    BE #(
        .N(N)
    ) sort_lv1_2 (
        .a  (bitonic_seq_reg[1]),
        .b  (bitonic_seq_reg[5]),
        .min(sort_lv1_2_min),
        .max(sort_lv1_2_max)
    );
    BE #(
        .N(N)
    ) sort_lv1_3 (
        .a  (bitonic_seq_reg[2]),
        .b  (bitonic_seq_reg[6]),
        .min(sort_lv1_3_min),
        .max(sort_lv1_3_max)
    );
    BE #(
        .N(N)
    ) sort_lv1_4 (
        .a  (bitonic_seq_reg[3]),
        .b  (bitonic_seq_reg[7]),
        .min(sort_lv1_4_min),
        .max(sort_lv1_4_max)
    );

    BE #(
        .N(N)
    ) sort_lv2_1 (
        .a  (sort_lv1_1_min),
        .b  (sort_lv1_3_min),
        .min(sort_lv2_1_min),
        .max(sort_lv2_1_max)
    );
    BE #(
        .N(N)
    ) sort_lv2_2 (
        .a  (sort_lv1_1_max),
        .b  (sort_lv1_3_max),
        .min(sort_lv2_2_min),
        .max(sort_lv2_2_max)
    );
    BE #(
        .N(N)
    ) sort_lv2_3 (
        .a  (sort_lv1_2_min),
        .b  (sort_lv1_4_min),
        .min(sort_lv2_3_min),
        .max(sort_lv2_3_max)
    );
    BE #(
        .N(N)
    ) sort_lv2_4 (
        .a  (sort_lv1_2_max),
        .b  (sort_lv1_4_max),
        .min(sort_lv2_4_min),
        .max(sort_lv2_4_max)
    );

    BE #(
        .N(N)
    ) sort_lv3_1 (
        .a  (sort_lv2_1_min),
        .b  (sort_lv2_3_min),
        .min(i),
        .max(j)
    );
    BE #(
        .N(N)
    ) sort_lv3_2 (
        .a  (sort_lv2_1_max),
        .b  (sort_lv2_3_max),
        .min(k),
        .max(l)
    );
    BE #(
        .N(N)
    ) sort_lv3_3 (
        .a  (sort_lv2_2_min),
        .b  (sort_lv2_4_min),
        .min(m),
        .max(n)
    );
    BE #(
        .N(N)
    ) sort_lv3_4 (
        .a  (sort_lv2_2_max),
        .b  (sort_lv2_4_max),
        .min(o),
        .max(p)
    );

endmodule
