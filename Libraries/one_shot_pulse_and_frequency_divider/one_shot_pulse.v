module one_shot_pulse (
    input  rst_n,
    input  clk,
    input  btn_u,
    input  btn_lw,
    input  btn_lft,
    input  btn_ri,
    output btn_u_pulse,
    output btn_lw_pulse,
    output btn_lft_pulse,
    output btn_ri_pulse
);

    reg [15:0] count;
    //===========================
    //	 Frequency Division
    //===========================
    //100MHz -> 25MHz
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count <= 0;
        else count <= count + 1;
    end
    wire clk_25 = count[1];

    //===========================
    //	 One_shot_pulse
    //===========================
    reg  btn_u_press_flag;
    reg  btn_lw_press_flag;
    reg  btn_lft_press_flag;
    reg  btn_ri_press_flag;

    //One pulse shot generator for btns
    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            // btn_c_press_flag <= 0;
            btn_u_press_flag   <= 0;
            btn_lw_press_flag  <= 0;
            btn_lft_press_flag <= 0;
            btn_ri_press_flag  <= 0;
        end else begin
            // btn_c_press_flag <= btn_c;
            btn_u_press_flag   <= btn_u;
            btn_lw_press_flag  <= btn_lw;
            btn_lft_press_flag <= btn_lft;
            btn_ri_press_flag  <= btn_ri;
        end
    end

    assign btn_u_pulse   = {btn_u, btn_u_press_flag} == 2'b10 ? 1 : 0;
    assign btn_lw_pulse  = {btn_lw, btn_lw_press_flag} == 2'b10 ? 1 : 0;
    assign btn_lft_pulse = {btn_lft, btn_lft_press_flag} == 2'b10 ? 1 : 0;
    assign btn_ri_pulse  = {btn_ri, btn_ri_press_flag} == 2'b10 ? 1 : 0;


endmodule
