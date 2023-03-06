`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Dmitry Matyunin (https://github.com/mcjtag)
// 
// Create Date: 17.05.2020 20:18:34
// Design Name: 
// Module Name: axis_bitonic_node
// Project Name: axis_bitonic_sort
// Target Devices:
// Tool Versions:
// Description:
// Dependencies:
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// License: MIT
//  Copyright (c) 2019 Dmitry Matyunin
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
// 
//////////////////////////////////////////////////////////////////////////////////

module axis_bitonic_node #(
	parameter DATA_WIDTH = 16,
	parameter ORDER = 0,
	parameter POLARITY = 0,
	parameter SIGNED = 0
)
(
	input wire aclk,
	input wire aresetn,
	input wire [DATA_WIDTH*2**(ORDER+1)-1:0]s_axis_tdata,
	input wire s_axis_tvalid,
	output wire s_axis_tready,
	input wire s_axis_tlast,
	output wire [DATA_WIDTH*2**(ORDER+1)-1:0]m_axis_tdata,
	output wire m_axis_tvalid,
	input wire m_axis_tready,
	output wire m_axis_tlast
);

localparam COMP_NUM = 2**ORDER;

genvar i;

generate for (i = 0; i < COMP_NUM; i = i + 1) begin: COMP
	wire [DATA_WIDTH-1:0]a;
	wire [DATA_WIDTH-1:0]b;
	wire [DATA_WIDTH-1:0]h;
	wire [DATA_WIDTH-1:0]l;
	
	assign a = s_axis_tdata[DATA_WIDTH*(i + 1 + COMP_NUM * 0)-1-:DATA_WIDTH];
	assign b = s_axis_tdata[DATA_WIDTH*(i + 1 + COMP_NUM * 1)-1-:DATA_WIDTH];
	assign m_axis_tdata[DATA_WIDTH*(i + 1 + COMP_NUM * 0)-1-:DATA_WIDTH] = h;
	assign m_axis_tdata[DATA_WIDTH*(i + 1 + COMP_NUM * 1)-1-:DATA_WIDTH] = l;

	if (i == 0) begin
		axis_bitonic_comp #(
			.DATA_WIDTH(DATA_WIDTH),
			.POLARITY(POLARITY),
			.SIGNED(SIGNED)
		) abc_inst (
			.aclk(aclk),
			.aresetn(aresetn),
			.s_axis_tdata({b,a}),
			.s_axis_tvalid(s_axis_tvalid),
			.s_axis_tready(s_axis_tready),
			.s_axis_tlast(s_axis_tlast),
			.m_axis_tdata({h,l}),
			.m_axis_tvalid(m_axis_tvalid),
			.m_axis_tready(m_axis_tready),
			.m_axis_tlast(m_axis_tlast)
		);
	end else begin
		axis_bitonic_comp #(
			.DATA_WIDTH(DATA_WIDTH),
			.POLARITY(POLARITY),
			.SIGNED(SIGNED)
		) abc_inst (
			.aclk(aclk),
			.aresetn(aresetn),
			.s_axis_tdata({b,a}),
			.s_axis_tvalid(s_axis_tvalid),
			.s_axis_tready(),
			.s_axis_tlast(s_axis_tlast),
			.m_axis_tdata({h,l}),
			.m_axis_tvalid(),
			.m_axis_tready(m_axis_tready),
			.m_axis_tlast()
		);
	end
end endgenerate

endmodule
