module Inside (
input [3:0] x,
input [3:0] y,
input [3:0] circle_x,
input [3:0] circle_y,
output reg is_inside // 1: is inside, 0: is outside
);

wire [4:0] signed dis_x = circle_x - x;
wire [4:0] signed dis_y = circle_y - y;

wire [4:0] abs_dis_x = dis_x[4] ? ~dis_x + 1 : dis_x;
wire [4:0] abs_dis_y = dis_y[4] ? ~dis_y + 1 : dis_y;

wire [5:0] dis =  abs_dis_x + abs_dis_y;

always @(*) begin 
	if (dis <= 4) begin
		is_inside = 1;
	end 
	else if(abs_dis_x == 2 && abs_dis_y == 3) begin
		is_inside = 1;
	end
	else if(abs_dis_y == 2 && abs_dis_x == 3) begin
		is_inside = 1;
	end
	else begin
		is_inside = 0;
	end
end

endmodule

/*

module Inside (
input [3:0] x,
input [3:0] y,
input [3:0] circle_x,
input [3:0] circle_y,
output reg is_inside // 1: is inside, 0: is outside
);

wire [4:0] signed dis_x = circle_x - x;
wire [4:0] signed dis_y = circle_y - y;

wire [9:0] dis =  dis_x^2 + dis_y^2;

always @(*) begin 
	if (dis <= 16) begin
		is_inside = 1;
	end 
	else begin
		is_inside = 0;
	end
end

endmodule
*/