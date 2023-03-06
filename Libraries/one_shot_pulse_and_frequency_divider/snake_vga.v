module snake_vga (
    input rst_n,
    input clk,    //100MHz
    input btn_u,
    input btn_lw,
    input btn_lft,
    input btn_ri,
    output VGA_HS,    //Horizontal synchronize signal
    output VGA_VS,    //Vertical synchronize signal
    output [3:0] VGA_R,    //Signal RED
    output [3:0] VGA_G,    //Signal Green
    output [3:0] VGA_B     //Signal Blue
);
    //PIXEL_WIDTH, assume a 12 x 16 grids on VGA
    parameter PIXEL_WIDTH = 40;

    //APPLE LOCATIONS
    parameter APPLE_X_1 = 7;
    parameter APPLE_Y_1 = 8;

    parameter APPLE_X_2 = 10;
    parameter APPLE_Y_2 = 11;

    parameter APPLE_X_3 = 1;
    parameter APPLE_Y_3 = 1;

    parameter APPLE_X_4 = 2;
    parameter APPLE_Y_4 = 6;

    //Horizontal Parameter
    parameter H_FRONT = 16;
    parameter H_SYNC = 96;
    parameter H_BACK = 48;
    parameter H_ACT = 640;
    parameter H_TOTAL = H_FRONT + H_SYNC + H_BACK + H_ACT;

    //Vertical Parameter
    parameter V_FRONT = 10;
    parameter V_SYNC = 2;
    parameter V_BACK = 33;
    parameter V_ACT = 480;
    parameter V_TOTAL = V_FRONT + V_SYNC + V_BACK + V_ACT;

    //SNAKE STATES
    parameter UP = 0;
    parameter DOWN = 1;
    parameter RIGHT = 2;
    parameter LEFT = 3;


    //Add input buttons for more input options, then we can change the constraint file so that the button would be binded to these inputs
    reg [24:0] count;
    reg [1:0] count_vga;
    wire d_clk;


    //===========================
    //	 One_shot_pulse
    //===========================
    reg btn_u_press_flag;
    reg btn_lw_press_flag;
    reg btn_lft_press_flag;
    reg btn_ri_press_flag;

    wire btn_u_pulse;
    wire btn_lw_pulse;
    wire btn_lft_pulse;
    wire btn_ri_pulse;


    // 轉為 「單一脈衝」 One pulse shot generator for btns
    always @(posedge clk or negedge rst_n) begin
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


    //===========================
    //	 FSM
    //===========================

    //state registers
    reg [2:0] current_state, next_state;

    wire clk_25;  //25MHz clk

    reg [9:0] H_cnt;
    reg [9:0] V_cnt;
    reg vga_hs;  //register for horizontal synchronize signal
    reg vga_vs;  //register for vertical synchronize signal
    reg [9:0] X;  //from 1~640
    reg [8:0] Y;  //from 1~480

    assign VGA_HS = vga_hs;
    assign VGA_VS = vga_vs;

    reg [11:0] VGA_RGB;

    assign VGA_R = VGA_RGB[11:8];
    assign VGA_G = VGA_RGB[7:4];
    assign VGA_B = VGA_RGB[3:0];

    //100MHz -> 25MHz
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) count_vga <= 0;
        else count_vga <= count_vga + 1;
    end
    assign clk_25 = count[1];

    //Horizontal counter
    always @(posedge clk_25 or negedge rst_n) begin  //count 0~800
        H_cnt <= (!rst_n) ? H_TOTAL : (H_cnt < H_TOTAL) ? H_cnt + 1'b1 : 10'd0;
    end

    //Vertical counter
    always @(posedge VGA_HS or negedge rst_n) begin  //count 0~525
        V_cnt <= (!rst_n) ? V_TOTAL : (V_cnt < V_TOTAL) ? V_cnt + 1'b1 : 10'd0;
    end

    //Horizontal Generator: Refer to the pixel clock
    always @(posedge clk_25 or negedge rst_n) begin
        if (!rst_n) begin
            vga_hs <= 1;
            X      <= 0;
        end else begin
            //Horizontal Sync
            if (H_cnt <= H_SYNC)  //Sync pulse start
                vga_hs <= 1'b0;  //horizontal synchronize pulse
            else vga_hs <= 1'b1;
            //Current X
            if ((H_cnt >= H_SYNC + H_BACK) && (H_cnt <= H_TOTAL - H_FRONT)) X <= X + 1;
            else X <= 0;
        end
    end

    //Vertical Generator: Refer to the horizontal sync
    always @(posedge VGA_HS or negedge rst_n) begin
        if (!rst_n) begin
            vga_vs <= 1;
            Y      <= 0;
        end else begin
            //Vertical Sync
            if (V_cnt <= V_SYNC)  //Sync pulse start
                vga_vs <= 0;
            else vga_vs <= 1;
            //Current Y
            if ((V_cnt >= V_SYNC + V_BACK) && (V_cnt <= V_TOTAL - V_FRONT)) Y <= Y + 1;
            else Y <= 0;
        end
    end

    // frequency division for snake_clk and debounce_ckt
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= 0;
        end else begin
            count <= count + 1;
        end
    end

    // assign d_clk = count[22];
    assign snake_clk = count[24];

    reg [4:0] apple_pos_reg[0:1];
    reg [4:0] snake_pos_reg[0:4][0:1];
    reg [3:0] snake_length_reg;

    wire snake_length_2_flag = snake_length_reg == 'd1;
    wire snake_length_3_flag = snake_length_reg == 'd2;
    wire snake_length_4_flag = snake_length_reg == 'd3;
    wire max_snake_length_rch_flag = (snake_length_reg == 'd4);


    //index 1 for x ,index 0 for y
    wire apple_hit_flag = ((snake_pos_reg[0][1]== apple_pos_reg[1]) && (snake_pos_reg[0][0]== apple_pos_reg[0]));
    wire upper_bondry_rch_flag = snake_pos_reg[0][0] == 'd0;
    wire lower_bondry_rch_flag = snake_pos_reg[0][0] == 'd11;
    wire lft_bondry_rch_flag = snake_pos_reg[0][1] == 'd0;
    wire right_bondry_rch_flag = snake_pos_reg[0][1] == 'd15;

    //SNAKE MAIN_CTR
    always @(posedge snake_clk or negedge rst_n) begin
        current_state <= !rst_n ? UP : next_state;
    end

    always @(*) begin
        case (current_state)
            UP: begin
                case ({
                    btn_u_pulse, btn_lw_pulse, btn_lft_pulse, btn_ri_pulse
                })
                    4'b0010: begin
                        next_state = LEFT;
                    end
                    4'b0001: begin
                        next_state = RIGHT;
                    end
                    default: begin
                        next_state = UP;
                    end
                endcase
            end
            DOWN: begin
                case ({
                    btn_u_pulse, btn_lw_pulse, btn_lft_pulse, btn_ri_pulse
                })
                    4'b0010: begin
                        next_state = LEFT;
                    end
                    4'b0001: begin
                        next_state = RIGHT;
                    end
                    default: begin
                        next_state = DOWN;
                    end
                endcase
            end
            RIGHT: begin
                case ({
                    btn_u_pulse, btn_lw_pulse, btn_lft_pulse, btn_ri_pulse
                })
                    4'b1000: begin
                        next_state = UP;
                    end
                    4'b0100: begin
                        next_state = DOWN;
                    end
                    default: begin
                        next_state = RIGHT;
                    end
                endcase
            end
            LEFT: begin
                case ({
                    btn_u_pulse, btn_lw_pulse, btn_lft_pulse, btn_ri_pulse
                })
                    4'b1000: begin
                        next_state = UP;
                    end
                    4'b0100: begin
                        next_state = DOWN;
                    end
                    default: begin
                        next_state = LEFT;
                    end
                endcase
            end
            default: begin
                next_state = current_state;
            end
        endcase
    end

    //snake_length_reg
    always @(posedge snake_clk or negedge rst_n) begin
        if (!rst_n) begin
            snake_length_reg <= 'd0;
        end
    else if(apple_hit_flag && !max_snake_length_rch_flag)
    begin // if we got the apple, length ++
            snake_length_reg <= snake_length_reg + 'd1;
        end else begin
            snake_length_reg <= snake_length_reg;
        end
    end



    //(1,0) means (x,y)
    //5 SECTIONS OF SNAKE on the grid
    //snake_pos_reg[0]
    always @(posedge snake_clk or negedge rst_n) begin
        if (!rst_n) begin  // origin snake (x,y) = (5,5)
            {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {5'd5, 5'd5};
        end else begin
            case (current_state)
                UP: begin
                    {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {
                        snake_pos_reg[0][1],
                        (upper_bondry_rch_flag ? 5'd11 : snake_pos_reg[0][0] - 5'd1)
                    };
                end
                DOWN: begin
                    {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {
                        snake_pos_reg[0][1],
                        (lower_bondry_rch_flag ? 5'd0 : snake_pos_reg[0][0] + 5'd1)
                    };
                end
                RIGHT: begin
                    {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {
                        right_bondry_rch_flag ? 5'd0 : snake_pos_reg[0][1] + 5'd1,
                        snake_pos_reg[0][0]
                    };
                end
                LEFT: begin
                    {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {
                        lft_bondry_rch_flag ? 5'd15 : snake_pos_reg[0][1] - 5'd1,
                        snake_pos_reg[0][0]
                    };
                end
                default: begin
                    {snake_pos_reg[0][1], snake_pos_reg[0][0]} <= {
                        snake_pos_reg[0][1], snake_pos_reg[0][0]
                    };
                end
            endcase
        end
    end

    //snake_pos_reg[1]~[4]
    always @(posedge snake_clk or negedge rst_n) begin
        if (!rst_n) begin  //(x,y)
            {snake_pos_reg[1][1], snake_pos_reg[1][0]} <= {5'd5, 5'd5 + 5'd1};
            {snake_pos_reg[2][1], snake_pos_reg[2][0]} <= {5'd5, 5'd5 + 5'd2};
            {snake_pos_reg[3][1], snake_pos_reg[3][0]} <= {5'd5, 5'd5 + 5'd3};
            {snake_pos_reg[4][1], snake_pos_reg[4][0]} <= {5'd5, 5'd5 + 5'd4};
        end else begin
            {snake_pos_reg[1][1], snake_pos_reg[1][0]} <= {
                snake_pos_reg[0][1], snake_pos_reg[0][0]
            };
            {snake_pos_reg[2][1], snake_pos_reg[2][0]} <= {
                snake_pos_reg[1][1], snake_pos_reg[1][0]
            };
            {snake_pos_reg[3][1], snake_pos_reg[3][0]} <= {
                snake_pos_reg[2][1], snake_pos_reg[2][0]
            };
            {snake_pos_reg[4][1], snake_pos_reg[4][0]} <= {
                snake_pos_reg[3][1], snake_pos_reg[3][0]
            };
        end
    end

    //apple_pos_reg
    always @(posedge snake_clk or negedge rst_n) begin
        if (!rst_n) begin
            apple_pos_reg[0] <= APPLE_Y_1;
            apple_pos_reg[1] <= APPLE_X_1;
        end else begin
            case (snake_length_reg)
                1: begin
                    apple_pos_reg[0] <= APPLE_Y_2;
                    apple_pos_reg[1] <= APPLE_X_2;
                end
                2: begin
                    apple_pos_reg[0] <= APPLE_Y_3;
                    apple_pos_reg[1] <= APPLE_X_3;
                end
                3: begin
                    apple_pos_reg[0] <= APPLE_Y_4;
                    apple_pos_reg[1] <= APPLE_X_4;
                end
                default: begin
                    apple_pos_reg[0] <= apple_pos_reg[0];
                    apple_pos_reg[1] <= apple_pos_reg[1];
                end
            endcase
        end
    end


    //Coordinate transformation from 12x16 grid coordinates to 480x640 VGA coordinates
    wire [10:0] snake_0_origin_x = snake_pos_reg[0][1] * PIXEL_WIDTH;
    wire [10:0] snake_0_origin_y = snake_pos_reg[0][0] * PIXEL_WIDTH;
    wire [10:0] snake_0_bound_x = (snake_pos_reg[0][1] * PIXEL_WIDTH) + PIXEL_WIDTH;
    wire [10:0] snake_0_bound_y = (snake_pos_reg[0][0] * PIXEL_WIDTH) + PIXEL_WIDTH;

    wire [10:0] snake_1_origin_x = snake_pos_reg[1][1] * PIXEL_WIDTH;
    wire [10:0] snake_1_origin_y = snake_pos_reg[1][0] * PIXEL_WIDTH;
    wire [10:0] snake_1_bound_x = (snake_pos_reg[1][1] * PIXEL_WIDTH) + PIXEL_WIDTH;
    wire [10:0] snake_1_bound_y = (snake_pos_reg[1][0] * PIXEL_WIDTH) + PIXEL_WIDTH;

    wire [10:0] snake_2_origin_x = snake_pos_reg[2][1] * PIXEL_WIDTH;
    wire [10:0] snake_2_origin_y = snake_pos_reg[2][0] * PIXEL_WIDTH;
    wire [10:0] snake_2_bound_x = (snake_pos_reg[2][1] * PIXEL_WIDTH) + PIXEL_WIDTH;
    wire [10:0] snake_2_bound_y = (snake_pos_reg[2][0] * PIXEL_WIDTH) + PIXEL_WIDTH;

    wire [10:0] snake_3_origin_x = snake_pos_reg[3][1] * PIXEL_WIDTH;
    wire [10:0] snake_3_origin_y = snake_pos_reg[3][0] * PIXEL_WIDTH;
    wire [10:0] snake_3_bound_x = (snake_pos_reg[3][1] * PIXEL_WIDTH) + PIXEL_WIDTH;
    wire [10:0] snake_3_bound_y = (snake_pos_reg[3][0] * PIXEL_WIDTH) + PIXEL_WIDTH;

    wire [10:0] snake_4_origin_x = snake_pos_reg[4][1] * PIXEL_WIDTH;
    wire [10:0] snake_4_origin_y = snake_pos_reg[4][0] * PIXEL_WIDTH;
    wire [10:0] snake_4_bound_x = (snake_pos_reg[4][1] * PIXEL_WIDTH) + PIXEL_WIDTH;
    wire [10:0] snake_4_bound_y = (snake_pos_reg[4][0] * PIXEL_WIDTH) + PIXEL_WIDTH;

    wire [10:0] apple_origin_x = apple_pos_reg[1] * PIXEL_WIDTH + PIXEL_WIDTH / 4;
    wire [10:0] apple_origin_y = apple_pos_reg[0] * PIXEL_WIDTH + PIXEL_WIDTH / 4;
    wire [10:0] apple_bound_x = apple_origin_x + PIXEL_WIDTH / 4;
    wire [10:0] apple_bound_y = apple_origin_y + PIXEL_WIDTH / 4;


    //Snake has the highest priority, then apple then blackground
    //VGA_DISPLAY
    always @(*) begin
        //Snake white
        if((X >= snake_0_origin_x) && (X < snake_0_bound_x) && (Y > snake_0_origin_y) && (Y <= snake_0_bound_y)) // head of snake 0
    begin
            VGA_RGB = 12'hfff;  //Snake White
        end
    else if ((X >= snake_1_origin_x) && (X < snake_1_bound_x) && (Y > snake_1_origin_y) && (Y <= snake_1_bound_y)
             && (snake_length_2_flag || snake_length_3_flag || snake_length_4_flag || max_snake_length_rch_flag)) // snake mid section 1
    begin
            VGA_RGB = 12'hfff;
        end
    else if ((X >= snake_2_origin_x) && (X < snake_2_bound_x) && (Y > snake_2_origin_y) && (Y <= snake_2_bound_y)
             && (snake_length_3_flag || snake_length_4_flag || max_snake_length_rch_flag)) // snake mid section 2
    begin
            VGA_RGB = 12'hfff;
        end
    else if((X >= snake_3_origin_x) && (X < snake_3_bound_x) && (Y > snake_3_origin_y) && (Y <= snake_3_bound_y)
            && (snake_length_4_flag || max_snake_length_rch_flag)) //snake mid section 3
    begin
            VGA_RGB = 12'hfff;
        end
    else if((X >= snake_4_origin_x) && (X < snake_4_bound_x) && (Y > snake_4_origin_y) && (Y <= snake_4_bound_y)
            && max_snake_length_rch_flag) //snake Final section
    begin
            VGA_RGB = 12'hfff;
        end
    else if ((X >= apple_origin_x) && (X <=  apple_bound_x) && (Y > apple_origin_y) && (Y <= apple_bound_y)) // Apple PIXEL
    begin
            VGA_RGB = 12'hf00;  //APPLE RED
        end else begin
            VGA_RGB = 12'h000;  // ELSE BLACKBACKGROUND
        end
    end


    //VGA DISPLAY
    // always@(*)
    // begin
    //     if( (X >= 1) && (X <= 80) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'h000;
    //     else if( (X >= 81) && (X <= 160) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'h00f;
    //     else if( (X >= 161) && (X <= 240) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'h0f0;
    //     else if( (X >= 241) && (X <= 320) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'h0ff;
    //     else if( (X >= 321) && (X <= 400) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'hf00;
    //     else if( (X >= 401) && (X <= 480) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'hf0f;
    //     else if( (X >= 481) && (X <= 560) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'hff0;
    //     else if( (X >= 561) && (X <= 640) && (Y > 0) && (Y <= 480) )
    //         VGA_RGB = 12'hfff;
    //     else
    //         VGA_RGB = 12'h000;
    // end
endmodule
