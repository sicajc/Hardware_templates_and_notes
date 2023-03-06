// 2023 FPGA
// FIANL : Polish Notation(PN)
//
// -----------------------------------------------------------------------------
// ©Communication IC & Signal Processing Lab 716
// -----------------------------------------------------------------------------
// Author : JACKY-YEH
// File   : PN.v
// Create : 2023-03-03 15:19:54
// Revise : 2023-03-05 13:19:54
// Editor : vscode , tab size (4)
// -----------------------------------------------------------------------------
`define C2Q 5
module PN (
    input clk,
    input rst_n,
    input [1:0] mode,
    input operator,
    input [2:0] in,
    input in_valid,
    output reg out_valid,
    output reg signed [31:0] out
);

    //================================================================
    //   PARAMETER/INTEGER
    //================================================================
    //integer
    integer i;
    parameter WORD = 16;
    parameter BUFFER_LEN = 16;
    localparam CNT_LEN = 4;
    localparam NUM_OF_RESULT = 4;
    //================================================================
    //   States
    //================================================================
    //======================
    //   L1 MAIN FSM
    //======================
    localparam IDLE = 'd0;
    localparam RD_DATA = 'd1;
    localparam EVALUATION = 'd2;
    localparam SORT = 'd3;
    localparam DONE = 'd4;


    //======================
    //   MODES
    //======================
    localparam POSTFIX_BURST = 'd0;
    localparam POSTFIX = 'd1;
    localparam PREFIX_BURST = 'd2;
    localparam PREFIX = 'd3;

    //======================
    //   STACK FSM
    //======================
    localparam DET_TYPE = 'd0;
    localparam PERFORM_OP_POP1 = 'd1;
    localparam PERFORM_OP_POP2 = 'd2;
    localparam PERFORM_OP_PUSH = 'd3;
    localparam PERFORM_CALCULATION = 'd4;
    localparam PUSH_MID_RESULT = 'd5;

    //======================
    //   ALU type
    //======================
    localparam ADD = 3'b000;
    localparam SUBTRACT = 3'b001;
    localparam MULT = 3'b010;
    localparam ABSOLUTE = 3'b011;

    //================================================================
    //   REG/WIRE
    //================================================================
    reg signed [WORD-1:0] alu_out;
    reg signed [WORD-1:0] alu_buf1;
    reg signed [WORD-1:0] alu_buf2;

    reg [WORD-1:0] data_buf[0:BUFFER_LEN-1];
    reg signed [WORD-1:0] result_buf[0:NUM_OF_RESULT-1];  // maximum of 4 values
    reg [CNT_LEN-1:0] strLen_cnt;
    reg [CNT_LEN-1:0] buf_index_cnt;
    reg [CNT_LEN-1:0] done_cnt;
    reg [CNT_LEN-1:0] result_reversed_cnt;
    reg [CNT_LEN-1:0] result_cnt;

    //======================
    //   FSM
    //======================
    reg [2:0] currentState, nextState;
    reg [2:0] stackCTR, stackCTRnext;
    reg  [     2:0] modeState;

    //======================
    //   STACK
    //======================
    wire            push;
    wire            pop;
    wire [WORD-1:0] stack_popped_value;
    wire [WORD-1:0] stack_pushed_value;
    wire            wn = push;
    wire            rn = pop;

    //======================
    //   state indicators
    //======================
    wire            state_IDLE = currentState == IDLE;
    wire            state_RD_DATA = currentState == RD_DATA;
    wire            state_EVALUATION = currentState == EVALUATION;
    wire            state_SORT = currentState == SORT;
    wire            state_DONE = currentState == DONE;


    wire            mode_POSTFIX_BURST = modeState == POSTFIX_BURST;
    wire            mode_POSTFIX = modeState == POSTFIX;
    wire            mode_PREFIX_BURST = modeState == PREFIX_BURST;
    wire            mode_PREFIX = modeState == PREFIX;

    wire            stack_DET_TYPE = stackCTR == DET_TYPE;
    wire            stack_POP1 = stackCTR == PERFORM_OP_POP1;
    wire            stack_POP2 = stackCTR == PERFORM_OP_POP2;
    wire            stack_PUSH = stackCTR == PERFORM_OP_PUSH;
    wire            stack_PUSH_MID_RESULT = stackCTR == PUSH_MID_RESULT;
    wire            stack_CALCULATION = stackCTR == PERFORM_CALCULATION;

    //======================
    //   current_char
    //======================
    wire [WORD-1:0] buf_current_char = data_buf[buf_index_cnt];

    //================================================================
    //   control flags
    //================================================================
    //======================
    //   evaluation done
    //======================
    reg             evaluation_done_f;

    always @(*) begin
        if ((mode_POSTFIX || mode_POSTFIX_BURST) && stack_CALCULATION) begin
            evaluation_done_f = buf_index_cnt == strLen_cnt - 1;
        end else if ((mode_PREFIX || mode_PREFIX_BURST) && stack_CALCULATION) begin
            evaluation_done_f = buf_index_cnt == 0;
        end else begin
            evaluation_done_f = 1'b0;
        end
    end

    wire timed_out_f = done_cnt == 'd30;
    wire is_operand_f = buf_current_char[15] == 1'b0;
    wire is_operator_f = buf_current_char[15] == 1'b1;
    wire burst_done_f = stack_CALCULATION;

    //================================================================
    //   Design
    //================================================================
    //======================
    //   FSM
    //======================
    //MAIN FSM
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            currentState <= IDLE;
        end else begin
            currentState <= nextState;
        end
    end

    wire output_done_f = result_cnt == 0;

    always @(*) begin
        case (currentState)
            IDLE: begin
                if (in_valid) begin
                    nextState = RD_DATA;
                end else begin
                    nextState = IDLE;
                end
            end
            RD_DATA: begin
                if (!in_valid) begin
                    nextState = EVALUATION;
                end else begin
                    nextState = RD_DATA;
                end
            end
            EVALUATION: begin
                if (evaluation_done_f && (mode_POSTFIX_BURST || mode_PREFIX_BURST)) begin
                    nextState = SORT;
                end else if (evaluation_done_f && (mode_PREFIX || mode_POSTFIX)) begin
                    nextState = DONE;
                end else begin
                    nextState = EVALUATION;
                end
            end
            SORT: begin
                nextState = DONE;
            end
            DONE: begin
                if (in_valid) begin
                    nextState = IDLE;
                end else if (mode_POSTFIX || mode_PREFIX) begin
                    nextState = IDLE;
                end else if (output_done_f) begin
                    nextState = IDLE;
                end else if (timed_out_f) begin
                    nextState = IDLE;
                end else begin
                    nextState = DONE;
                end
            end
            default: begin
                nextState = IDLE;
            end
        endcase
    end

    //MODE
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            modeState <= POSTFIX;
        end else if (state_IDLE && in_valid) begin
            case (mode)
                'd0: modeState <= PREFIX_BURST;
                'd1: modeState <= POSTFIX_BURST;
                'd2: modeState <= PREFIX;
                'd3: modeState <= POSTFIX;
                default: modeState <= PREFIX;
            endcase
        end else begin
            modeState <= modeState;
        end
    end

    //=================================================
    //   READ DATA
    //=================================================
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (!rst_n) begin
            strLen_cnt <= 'd0;

            for (i = 0; i < BUFFER_LEN; i = i + 1) begin
                data_buf[i] <= 'd0;
            end
        end else if (state_DONE) begin
            strLen_cnt <= 0;
        end else if ((state_RD_DATA || state_IDLE) && in_valid) begin
            strLen_cnt <= strLen_cnt + 1;

            if (operator) begin
                data_buf[strLen_cnt] <= {1'b1, 12'b0, in};
            end else begin
                data_buf[strLen_cnt] <= {1'b0, 12'b0, in};
            end
        end else begin
            strLen_cnt <= strLen_cnt;

            for (i = 0; i < BUFFER_LEN; i = i + 1) begin
                data_buf[i] <= data_buf[i];
            end
        end
    end

    //=================================================
    //   EVALUATION
    //=================================================
    //===============
    //   STACK
    //===============
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            stackCTR <= DET_TYPE;
        end else begin
            stackCTR <= stackCTRnext;
        end
    end

    always @(*) begin
        if (~rst_n) begin
            stackCTRnext = DET_TYPE;
        end else begin
            case (stackCTR)
                DET_TYPE: begin
                    if (state_EVALUATION) begin
                        case ({
                            is_operand_f, is_operator_f
                        })
                            2'b10: begin
                                stackCTRnext = PERFORM_OP_PUSH;
                            end
                            2'b01: begin
                                stackCTRnext = PERFORM_OP_POP1;
                            end
                            default: begin
                                stackCTRnext = DET_TYPE;
                            end
                        endcase
                    end else begin
                        stackCTRnext = DET_TYPE;
                    end
                end
                PERFORM_OP_PUSH: begin
                    stackCTRnext = DET_TYPE;
                end
                PERFORM_OP_POP1: begin
                    stackCTRnext = PERFORM_OP_POP2;
                end
                PERFORM_OP_POP2: begin
                    stackCTRnext = PERFORM_CALCULATION;
                end
                PUSH_MID_RESULT: begin
                    stackCTRnext = DET_TYPE;
                end
                PERFORM_CALCULATION: begin
                    if (mode_POSTFIX_BURST || mode_PREFIX_BURST) begin
                        stackCTRnext = DET_TYPE;
                    end else if (evaluation_done_f) begin
                        stackCTRnext = DET_TYPE;
                    end else begin
                        stackCTRnext = PUSH_MID_RESULT; // For postfix and prefix push the value back to stack.
                    end
                end
                default: begin
                    stackCTRnext = DET_TYPE;
                end
            endcase
        end
    end

    assign pop = stackCTRnext == PERFORM_OP_POP1 || stackCTRnext == PERFORM_OP_POP2;
    assign push = stack_PUSH || stack_PUSH_MID_RESULT;
    assign stack_pushed_value = stack_PUSH_MID_RESULT ? alu_out : buf_current_char;

    //===========================
    //   PERFORM OPERATION
    //===========================
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            buf_index_cnt <= 'd0;
        end else if (state_DONE) begin
            buf_index_cnt <= 0;
        end else if (currentState == RD_DATA && nextState == EVALUATION) begin
            case (modeState)
                PREFIX_BURST, PREFIX: buf_index_cnt <= strLen_cnt - 1;
                POSTFIX_BURST, POSTFIX: buf_index_cnt <= buf_index_cnt;
                default: buf_index_cnt <= buf_index_cnt;
            endcase
        end else if (stack_PUSH || stack_CALCULATION) begin
            case (modeState)
                PREFIX_BURST, PREFIX: buf_index_cnt <= buf_index_cnt - 1;
                POSTFIX_BURST, POSTFIX: buf_index_cnt <= buf_index_cnt + 1;
                default: buf_index_cnt <= buf_index_cnt;
            endcase
        end else begin
            buf_index_cnt <= buf_index_cnt;
        end
    end

    //============================
    //	   DONE
    //============================
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        // Used to counter in a reversed way during done state for POST_FIX
        if (~rst_n) begin
            result_reversed_cnt <= 0;
        end else if (state_RD_DATA) begin
            result_reversed_cnt <= 0;
        end else if (state_DONE) begin
            result_reversed_cnt <= result_reversed_cnt + 1;
        end else begin
            result_reversed_cnt <= result_reversed_cnt;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (~rst_n) begin
            done_cnt  <= 'd0;
            out_valid <= 'd0;
            out       <= 'd0;
        end else if (timed_out_f) begin
            done_cnt  <= 'd0;
            out_valid <= 'd0;
            out       <= 'd0;
        end else if (state_DONE) begin
            done_cnt  <= done_cnt + 1;
            out_valid <= 1'b1;
            if (mode_PREFIX_BURST) begin
                out <= result_buf[result_cnt];
            end else if (mode_POSTFIX_BURST) begin
                out <= result_buf[result_reversed_cnt];
            end else if (mode_POSTFIX || mode_PREFIX) begin
                out <= alu_out;
            end else begin
                out <= out;
            end
        end else begin
            out_valid <= 'd0;
            out       <= 'd0;
            done_cnt  <= done_cnt;
        end
    end

    //======================
    //  ALU
    //======================
    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (!rst_n) begin
            alu_buf1 <= 'd0;
            alu_buf2 <= 'd0;
        end else if (stack_POP1) begin
            alu_buf1 <= stack_popped_value;
            alu_buf2 <= alu_buf2;
        end else if (stack_POP2) begin
            alu_buf1 <= alu_buf1;
            alu_buf2 <= stack_popped_value;
        end else begin
            alu_buf1 <= alu_buf1;
            alu_buf2 <= alu_buf2;
        end
    end


    always @(*) begin
        if (!rst_n) begin
            alu_out = 'd0;
        end else if (stack_POP1) begin
            alu_out = alu_out;
        end else if (stack_POP2) begin
            alu_out = alu_out;
        end else if (stack_CALCULATION) begin
            case (buf_current_char[2:0])
                ADD: begin
                    alu_out = alu_buf1 + alu_buf2;
                end
                SUBTRACT: begin
                    if (mode_POSTFIX || mode_POSTFIX_BURST) begin
                        alu_out = alu_buf2 - alu_buf1;
                    end else begin
                        alu_out = alu_buf1 - alu_buf2;
                    end
                end
                MULT: begin
                    alu_out = alu_buf1 * alu_buf2;
                end
                ABSOLUTE: begin
                    if ($signed(alu_buf1 + alu_buf2) < 0) begin
                        alu_out = -(alu_buf1 + alu_buf2);
                    end else begin
                        alu_out = alu_buf1 + alu_buf2;
                    end
                end
                default: begin
                    alu_out = alu_out;
                end
            endcase

        end else begin
            alu_out = alu_out;
        end
    end

    //==========================
    //	   RESULT BUFFER & cnt
    //==========================
    wire signed [WORD-1:0] result_rd[0:3];
    wire signed [WORD-1:0] sorted_result_d[0:7];

    genvar idx;

    generate
        for (idx = 0; idx < 4; idx = idx + 1) begin
            assign result_rd[idx] = result_buf[idx];
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        //synopsys_translate_off
        #`C2Q;
        //synopsys_translate_on
        if (!rst_n) begin
            result_cnt <= 'd0;
            for (i = 0; i < NUM_OF_RESULT; i = i + 1) begin
                result_buf[i] <= 16'h0fff;
            end
        end else if (state_RD_DATA) begin
            result_cnt <= 'd0;
            for (i = 0; i < NUM_OF_RESULT; i = i + 1) begin
                result_buf[i] <= 16'h0fff;
            end
        end else if (stack_CALCULATION && burst_done_f) begin
            result_cnt <= result_cnt + 1;
            result_buf[result_cnt] <= alu_out;
        end else if (state_SORT) begin
            for (i = 0; i < 4; i = i + 1) begin
                result_buf[i] <= sorted_result_d[i];
            end
            result_cnt <= result_cnt - 1;
        end else if (state_DONE) begin
            result_cnt <= result_cnt - 1;
        end else begin
            result_cnt <= result_cnt;
            for (i = 0; i < NUM_OF_RESULT; i = i + 1) begin
                result_buf[i] <= result_buf[i];
            end
        end
    end

    //======================
    //	   MODULE: STACK
    //======================
    wire full;
    wire empty;

    LIFO stack (
        .in(stack_pushed_value),
        .clk(clk),
        .rst_n(rst_n),
        .wn(wn),
        .rn(rn),
        .out(stack_popped_value),
        .full(full),
        .empty(empty)
    );


    //===========================
    //	 MODULE: Sorter
    //===========================

    eight_value_bitonic_sorter #(
        .N(WORD)
    ) bitonics_sorter (
        .rst_n(rst_n),
        .clk(clk),
        //inputs
        .a(16'h0fff),
        .b(16'h0fff),
        .c(16'h0fff),
        .d(16'h0fff),
        .e(result_rd[0]),
        .f(result_rd[1]),
        .g(result_rd[2]),
        .h(result_rd[3]),
        //output
        .i(sorted_result_d[0]),
        .j(sorted_result_d[1]),
        .k(sorted_result_d[2]),
        .l(sorted_result_d[3]),
        .m(sorted_result_d[4]),
        .n(sorted_result_d[5]),
        .o(sorted_result_d[6]),
        .p(sorted_result_d[7])
    );



endmodule
