`define C2Q 0.8
module LASER (
    input CLK,
    input RST,
    input [3:0] X,
    input [3:0] Y,
    output reg [3:0] C1X,
    output reg [3:0] C1Y,
    output reg [3:0] C2X,
    output reg [3:0] C2Y,
    output reg DONE);

  //===============================
  //   PARAMETER
  //===============================
  parameter DATA_WIDTH      = 4;
  parameter VALID_POINT_NUM = 40;
  parameter VALID_POINT_NUM_BY_FOUR = 10;
  parameter ITER_NUM        = 4;
  parameter VALID_PTS_WIDTH       = 6;
  parameter RADIUS = 4;

  integer idx,depth;
  //===============================
  //   States
  //===============================
  reg[6:0] currentState, nextState;

  localparam IDLE         = 7'b0000001;
  localparam RD_DATA      = 7'b0000010;
  localparam FIRST_TRY_C1 = 7'b0000100;
  localparam FIND_C2      = 7'b0001000;
  localparam FIND_C1      = 7'b0010000;
  localparam EVAL         = 7'b0100000;
  localparam FINISH         = 7'b1000000;

  wire state_IDLE         = currentState[0];
  wire state_RD_DATA      = currentState[1];
  wire state_FIRST_TRY_C1 = currentState[2];
  wire state_FIND_C2      = currentState[3];
  wire state_FIND_C1      = currentState[4];
  wire state_EVAL         = currentState[5];
  wire state_DONE         = currentState[6];

  //============================
  //  CNTS,PTRS
  //============================
  reg[5:0] valid_pts_cnt;
  reg[DATA_WIDTH-1:0] row_ptr,col_ptr;
  reg[2:0] iters_cnt ;

  wire[1:0] rd_data_in_switch = valid_pts_cnt[1:0];

  //============================
  //  FF & BUFFERS
  //============================
  reg[VALID_PTS_WIDTH-1:0] curr_valid_Num_acc_ff;
  reg[VALID_PTS_WIDTH-1:0] best_Num_ff;
  reg[DATA_WIDTH-1:0] bestC1X_ff,bestC1Y_ff,bestC2X_ff,bestC2Y_ff;

  reg[DATA_WIDTH-1:0] valid_pts_X_cir_buf[0:VALID_POINT_NUM_BY_FOUR-1][0:3];
  reg[DATA_WIDTH-1:0] valid_pts_Y_cir_buf[0:VALID_POINT_NUM_BY_FOUR-1][0:3];

  //============================
  //   WIRE
  //============================
  reg [VALID_PTS_WIDTH-1:0] det_inside_C1;
  reg [VALID_PTS_WIDTH-1:0] det_inside_C2;
  reg [VALID_PTS_WIDTH-1:0] curr_valid_Num_acc_wr;

  wire[3:0] pt_is_in;

  // Last Value of the circular buffers.
  wire[DATA_WIDTH-1:0] current_validX1 = valid_pts_X_cir_buf[VALID_POINT_NUM_BY_FOUR-1][0];
  wire[DATA_WIDTH-1:0] current_validY1 = valid_pts_Y_cir_buf[VALID_POINT_NUM_BY_FOUR-1][0];

  wire[DATA_WIDTH-1:0] current_validX2 = valid_pts_X_cir_buf[VALID_POINT_NUM_BY_FOUR-1][1];
  wire[DATA_WIDTH-1:0] current_validY2 = valid_pts_Y_cir_buf[VALID_POINT_NUM_BY_FOUR-1][1];

  wire[DATA_WIDTH-1:0] current_validX3 = valid_pts_X_cir_buf[VALID_POINT_NUM_BY_FOUR-1][2];
  wire[DATA_WIDTH-1:0] current_validY3 = valid_pts_Y_cir_buf[VALID_POINT_NUM_BY_FOUR-1][2];

  wire[DATA_WIDTH-1:0] current_validX4 = valid_pts_X_cir_buf[VALID_POINT_NUM_BY_FOUR-1][3];
  wire[DATA_WIDTH-1:0] current_validY4 = valid_pts_Y_cir_buf[VALID_POINT_NUM_BY_FOUR-1][3];

  //================================================================
  //   DESIGN
  //================================================================
  //========================
  //   FLAGS
  //========================
  wire rd_data_done_f        = valid_pts_cnt == (VALID_POINT_NUM-1) && state_RD_DATA;


  wire valid_pts_traversed_f = valid_pts_cnt == (VALID_POINT_NUM_BY_FOUR-1) &&
       (state_FIND_C1 || state_FIND_C2 || state_FIRST_TRY_C1) ;

  wire first_try_done_f      = row_ptr == 15 && col_ptr == 15
       && state_FIRST_TRY_C1 && valid_pts_traversed_f;

  wire find_C2_done_f      = row_ptr == 15 && col_ptr == 15 && state_FIND_C2;

  wire find_C1_done_f      = row_ptr == 15 && col_ptr == 15 && state_FIND_C1;

  wire value_converged_f   = curr_valid_Num_acc_ff == best_Num_ff && state_EVAL;

  wire iters_done_f        = iters_cnt == ITER_NUM-1;
  //========================
  //   FSM
  //========================
  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      currentState <= RD_DATA;
    end
    else
    begin
      currentState <= nextState;
    end
  end

  always @(*)
  begin
    case (currentState)
      IDLE    :
      begin
        nextState            = RD_DATA;
      end
      RD_DATA :
      begin
        nextState            = rd_data_done_f   ? FIRST_TRY_C1 : RD_DATA;
      end
      FIRST_TRY_C1 :
      begin
        nextState            = first_try_done_f ? FIND_C2 : FIRST_TRY_C1;
      end
      FIND_C2 :
      begin
        nextState            = find_C2_done_f ? FIND_C1 : FIND_C2;
      end
      FIND_C1 :
      begin
        nextState            =  find_C1_done_f ? EVAL : FIND_C1;
      end
      EVAL    :
      begin
        nextState            = (iters_done_f || value_converged_f) ? FINISH:FIND_C2;
      end
      FINISH    :
      begin
        nextState            = IDLE;
      end
      default :
      begin
        nextState            = IDLE;
      end
    endcase
  end

  //========================
  //   PTRS, CNTS
  //========================
  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      row_ptr <= 0;
      col_ptr <= 0;
    end
    else if(state_IDLE || currentState != nextState)
    begin
      row_ptr <= 0;
      col_ptr <= 0;
    end
    else
    begin
      if(first_try_done_f || find_C1_done_f || find_C2_done_f)
      begin
        row_ptr  <= 0;
        col_ptr  <= 0;
      end
      else
      begin
        row_ptr  <= (col_ptr == 15) && valid_pts_traversed_f ?
                 row_ptr+1 : row_ptr ;

        col_ptr  <= valid_pts_traversed_f ?
                 ((col_ptr==15) ? 0 :col_ptr+1) : col_ptr;
      end
    end
  end

  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      valid_pts_cnt <= 0;
    end
    else if(state_IDLE || currentState != nextState || valid_pts_traversed_f)
    begin
      valid_pts_cnt <= 0;
    end
    else if(state_RD_DATA)
    begin
      valid_pts_cnt <= valid_pts_cnt + 1;
    end
    else if(state_FIND_C1 || state_FIND_C2 || state_FIRST_TRY_C1)
    begin
      valid_pts_cnt <= valid_pts_cnt + 1;
    end
    else
    begin
      valid_pts_cnt <= valid_pts_cnt;
    end
  end

  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      iters_cnt <= 0;
    end
    else if(state_IDLE)
    begin
      iters_cnt <= 0;
    end
    else if(find_C1_done_f)
    begin
      iters_cnt <= iters_cnt + 1;
    end
    else
    begin
      ;
    end
  end


  //===================================
  //   CIRCULAR SHIFT REGISTERS X4
  //===================================
  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    // if(RST)
    // begin
    //   for ( depth = 0 ; depth < 4 ; depth = depth + 1)
    //     for(idx = 0 ; idx < VALID_POINT_NUM_BY_FOUR ; idx = idx+1)
    //     begin
    //       valid_pts_X_cir_buf[idx][depth] <= 0;
    //       valid_pts_Y_cir_buf[idx][depth] <= 0;
    //     end
    // end
    // else
    if(state_RD_DATA)
    begin
      for ( depth = 0 ; depth < 4 ; depth = depth + 1)
        for(idx = 1 ; idx < VALID_POINT_NUM_BY_FOUR ; idx = idx+1)
        begin
          // Circulating from 1~10
          if(rd_data_in_switch==2'b00)
          begin
            valid_pts_X_cir_buf[idx][depth] <= valid_pts_X_cir_buf[idx-1][depth];
            valid_pts_Y_cir_buf[idx][depth] <= valid_pts_Y_cir_buf[idx-1][depth];
          end
        end

      // index 0, receive value
      case(rd_data_in_switch)
        2'b00:
        begin
          valid_pts_X_cir_buf[0][0] <= X;
          valid_pts_Y_cir_buf[0][0] <= Y;
        end
        2'b01:
        begin
          valid_pts_X_cir_buf[0][1] <= X;
          valid_pts_Y_cir_buf[0][1] <= Y;
        end
        2'b10:
        begin
          valid_pts_X_cir_buf[0][2] <= X;
          valid_pts_Y_cir_buf[0][2] <= Y;
        end
        2'b11:
        begin
          valid_pts_X_cir_buf[0][3] <= X;
          valid_pts_Y_cir_buf[0][3] <= Y;
        end
        default:
        begin
          valid_pts_X_cir_buf[0][0] <= 0;
          valid_pts_Y_cir_buf[0][0] <= 0;
        end
      endcase
    end
    else if((state_FIND_C1 || state_FIRST_TRY_C1 || state_FIND_C2))
    begin
      //&& !valid_pts_traversed_f
      // Keep shifting
      for(depth = 0 ;depth < 4 ; depth= depth + 1)
        for(idx = 1 ; idx < VALID_POINT_NUM_BY_FOUR ; idx = idx+1)
        begin
          valid_pts_X_cir_buf[idx][depth] <= valid_pts_X_cir_buf[idx-1][depth];
          valid_pts_Y_cir_buf[idx][depth] <= valid_pts_Y_cir_buf[idx-1][depth];

          valid_pts_X_cir_buf[0][depth] <= valid_pts_X_cir_buf[VALID_POINT_NUM_BY_FOUR-1][depth];
          valid_pts_Y_cir_buf[0][depth] <= valid_pts_Y_cir_buf[VALID_POINT_NUM_BY_FOUR-1][depth];
        end
    end
    else
    begin
      ;
    end
  end

  //============================
  //   BEST C1,C2 and BEST NUM
  //============================
  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      bestC1X_ff <= 0;
      bestC1Y_ff <= 0;
      bestC2X_ff <= 0;
      bestC2Y_ff <= 0;
      best_Num_ff <= 0;
    end
    else if(state_IDLE)
    begin
      bestC1X_ff <= 0;
      bestC1Y_ff <= 0;
      bestC2X_ff <= 0;
      bestC2Y_ff <= 0;
      best_Num_ff <= 0;
    end
    else if(state_FIRST_TRY_C1 || state_FIND_C1)
    begin
      if(curr_valid_Num_acc_wr >= best_Num_ff)
      begin
        bestC1X_ff <= col_ptr;
        bestC1Y_ff <= row_ptr;
        best_Num_ff <= curr_valid_Num_acc_wr;
      end
      else
      begin
        ;
      end
    end
    else if(state_FIND_C2)
    begin
      if(curr_valid_Num_acc_wr >= best_Num_ff)
      begin
        bestC2X_ff <= col_ptr;
        bestC2Y_ff <= row_ptr;
        best_Num_ff <= curr_valid_Num_acc_wr;
      end
      else
      begin
        ;
      end
    end
    else
    begin
      bestC1X_ff <= bestC1X_ff;
      bestC1Y_ff <= bestC1Y_ff;
      bestC2X_ff <= bestC2X_ff;
      bestC2Y_ff <= bestC2Y_ff;
      best_Num_ff <= best_Num_ff;
    end
  end

  //========================
  //   I/O
  //========================
  always @(posedge CLK)
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      C1X <= 0;
      C1Y <= 0;
      C2X <= 0;
      C2Y <= 0;
      DONE <= 0;
    end
    else if(state_IDLE)
    begin
      C1X <= 0;
      C1Y <= 0;
      C2X <= 0;
      C2Y <= 0;
      DONE <= 0;
    end
    else if(state_DONE)
    begin
      C1X <= bestC1X_ff;
      C1Y <= bestC1Y_ff;
      C2X <= bestC2X_ff;
      C2Y <= bestC2Y_ff;
      DONE <= 1;
    end
    else
    begin
      ;
    end
  end


  //========================
  //   DET VALID POINTS
  //========================
  reg[DATA_WIDTH-1:0] C1_Xin;
  reg[DATA_WIDTH-1:0] C1_Yin;

  wire[DATA_WIDTH-1:0] C1_Xin_feed = C1_Xin;
  wire[DATA_WIDTH-1:0] C1_Yin_feed = C1_Yin;

  reg[DATA_WIDTH-1:0] C2_Xin;
  reg[DATA_WIDTH-1:0] C2_Yin;

  wire[DATA_WIDTH-1:0] C2_Xin_feed = C2_Xin;
  wire[DATA_WIDTH-1:0] C2_Yin_feed = C2_Yin;

  always @(*)
  begin:DET_IN_INPUTS
    if(state_FIRST_TRY_C1)
    begin
      C1_Xin = col_ptr;
      C1_Yin = row_ptr;

      C2_Xin = col_ptr;
      C2_Yin = row_ptr;
    end
    else if(state_FIND_C1)
    begin
      C1_Xin = col_ptr;
      C1_Yin = row_ptr;

      C2_Xin = bestC2X_ff;
      C2_Yin = bestC2Y_ff;
    end
    else if(state_FIND_C2)
    begin
      C1_Xin = bestC1X_ff;
      C1_Yin = bestC1Y_ff;

      C2_Xin = col_ptr;
      C2_Yin = row_ptr;
    end
    else
    begin
      C1_Xin = 0;
      C1_Yin = 0;

      C2_Xin = 0;
      C2_Yin = 0;
    end
  end
  //========================
  //   Valid_num_acc
  //========================
  always @(posedge CLK )
  begin
    //synopsys_translate_off
    # `C2Q;
    //synopsys_translate_on
    if(RST)
    begin
      curr_valid_Num_acc_ff <= 0;
    end
    else if(state_IDLE || valid_pts_traversed_f||currentState!=nextState)
    begin
      curr_valid_Num_acc_ff <= 0;
    end
    else if(state_FIND_C1 || state_FIND_C2 || state_FIRST_TRY_C1)
    begin
      curr_valid_Num_acc_ff <= curr_valid_Num_acc_wr;
    end
    else
    begin
      curr_valid_Num_acc_ff <= curr_valid_Num_acc_ff;
    end
  end

  always @(*)
  begin
    curr_valid_Num_acc_wr = (pt_is_in[0] + pt_is_in[1]) + (pt_is_in[2] +pt_is_in[3])
    + curr_valid_Num_acc_ff;
  end

  //========================
  //   MODULES
  //========================
  // det_inside

  det_inside
    #(
      .RADIUS (RADIUS )
    )
    u_det_inside0(
      .circle1X (C1_Xin_feed ),
      .circle1Y (C1_Yin_feed ),
      .circle2X (C2_Xin_feed ),
      .circle2Y (C2_Yin_feed ),
      .validX   (current_validX1),
      .validY   (current_validY1),
      .pt_is_in (pt_is_in[0] )
    );


  det_inside
    #(
      .RADIUS (RADIUS )
    )
    u_det_inside1(
      .circle1X (C1_Xin_feed ),
      .circle1Y (C1_Yin_feed ),
      .circle2X (C2_Xin_feed ),
      .circle2Y (C2_Yin_feed ),
      .validX   (current_validX2),
      .validY   (current_validY2),
      .pt_is_in (pt_is_in[1] )
    );


  det_inside
    #(
      .RADIUS (RADIUS )
    )
    u_det_inside2(
      .circle1X (C1_Xin_feed ),
      .circle1Y (C1_Yin_feed ),
      .circle2X (C2_Xin_feed ),
      .circle2Y (C2_Yin_feed ),
      .validX   (current_validX3   ),
      .validY   (current_validY3  ),
      .pt_is_in (pt_is_in[2] )
    );

  det_inside
    #(
      .RADIUS (RADIUS )
    )
    u_det_inside3(
      .circle1X (C1_Xin_feed ),
      .circle1Y (C1_Yin_feed ),
      .circle2X (C2_Xin_feed ),
      .circle2Y (C2_Yin_feed ),
      .validX   (current_validX4   ),
      .validY   (current_validY4   ),
      .pt_is_in (pt_is_in[3] )
    );

endmodule


module det_inside(input[3:0] circle1X,
                    input[3:0] circle1Y,
                    input[3:0] circle2X,
                    input[3:0] circle2Y,
                    input[3:0] validX,
                    input[3:0] validY,
                    output pt_is_in);
  parameter RADIUS = 4;

  reg det_inside_C1,det_inside_C2;

  wire signed[3:0] dispC1X = validX - circle1X;
  reg[3:0] absDispC1X;

  wire signed[3:0] dispC1Y = validY - circle1Y;
  reg[3:0] absDispC1Y;

  wire signed[3:0] dispC2X = validX - circle2X;
  reg[3:0] absDispC2X;

  wire signed[3:0] dispC2Y = validY - circle2Y;
  reg[3:0] absDispC2Y;

  always @(*)
  begin: absoulute
    //C1
    if(dispC1X > 0)
    begin
      absDispC1X = dispC1X;
    end
    else
    begin
      absDispC1X = ~dispC1X+1;
    end

    if(dispC1Y > 0)
    begin
      absDispC1Y = dispC1Y;
    end
    else
    begin
      absDispC1Y = ~dispC1Y+1;
    end

    //C2
    if(dispC2X > 0)
    begin
      absDispC2X = dispC2X;
    end
    else
    begin
      absDispC2X = ~dispC2X+1;
    end

    if(dispC2Y > 0)
    begin
      absDispC2Y = dispC2Y;
    end
    else
    begin
      absDispC2Y = ~dispC2Y+1;
    end
  end

  always@(*)
  begin: DET_INSIDE
    // The point is inside if the displacement vector is (4,0) or (0,4)
    // or All the points with displacement less than 3 in x or y
    // except the (3,3) ones
    det_inside_C1 = ((absDispC1X == RADIUS) && (absDispC1Y == 0))
                  || ((absDispC1X == 0) && (absDispC1Y == RADIUS))
                  || (((absDispC1X <= RADIUS - 1) && (absDispC1Y <= RADIUS - 1))

                      && ~((absDispC1X == RADIUS - 1) && (absDispC1Y == RADIUS - 1)));

    det_inside_C2 = ((absDispC2X == RADIUS) && (absDispC2Y == 0))
                  || ((absDispC2X == 0) && (absDispC2Y == RADIUS))
                  || (((absDispC2X <= RADIUS - 1) && (absDispC2Y <= RADIUS - 1))

                      && ~((absDispC2X == RADIUS - 1) && (absDispC2Y == RADIUS - 1)));
  end

  assign pt_is_in = det_inside_C1 || det_inside_C2;

endmodule
