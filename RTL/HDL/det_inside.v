module det_inside(input[3:0] circle1X,
                  input[3:0] circle1Y,
                  input[3:0] circle2X,
                  input[3:0] circle2Y,
                  input[3:0] validX,
                  input[3:0] validY,
                  output pt_is_in);
    parameter RADIUS = 4;
    wire signed[4:0] dispC1X = validX - circle1X;
    reg[3:0] absDispC1X;

    wire signed[4:0] dispC1Y = validY - circle1Y;
    reg[3:0] absDispC1Y;

    wire signed[4:0] dispC2X = validX - circle2X;
    reg[3:0] absDispC2X;

    wire signed[4:0] dispC2Y = validY - circle2Y;
    reg[3:0] absDispC2Y;

    reg det_inside_C1,det_inside_C2;

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
        // or All the points with displacement of 3 in x or y except the (3,3) ones
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