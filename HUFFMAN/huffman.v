`include "huffproc.v"
`include "ctrl.v"

module huffman(clk, reset, gray_valid, gray_data, CNT_valid, CNT1, CNT2, CNT3, CNT4, CNT5, CNT6,
    code_valid, HC1, HC2, HC3, HC4, HC5, HC6, M1, M2, M3, M4, M5, M6);

input clk;
input reset;
input gray_valid;
input [7:0] gray_data;
output          CNT_valid;
output [7:0]    CNT1;
output [7:0]    CNT2;
output [7:0]    CNT3;
output [7:0]    CNT4;
output [7:0]    CNT5;
output [7:0]    CNT6;
output          code_valid;
output [7:0]    HC1;
output [7:0]    HC2;
output [7:0]    HC3;
output [7:0]    HC4;
output [7:0]    HC5;
output [7:0]    HC6;
output [7:0]    M1;
output [7:0]    M2;
output [7:0]    M3;
output [7:0]    M4;
output [7:0]    M5;
output [7:0]    M6;


        huffproc        huffproc(.clk(clk),
                                 .reset(reset),
                                 .gray_valid(gray_valid),
                                 .gray_data(gray_data),
                                 .CNT_valid(CNT_valid),
                                 .comp_en(comp_en),
                                 .comb_en(comb_en),
                                 .order_en(order_en),
                                 .split_en(split_en),
                                 .out_en(out_en),
                                 .CNT1(CNT1),
                                 .CNT2(CNT2),
                                 .CNT3(CNT3),
                                 .CNT4(CNT4),
                                 .CNT5(CNT5),
                                 .CNT6(CNT6),
                                 .code_valid(code_valid),
                                 .comp_done(comp_done),
                                 .comb_done(comb_done),
                                 .split_done(split_done),
                                 .order_done(order_done),
                                 .HC1(HC1),
                                 .HC2(HC2),
                                 .HC3(HC3),
                                 .HC4(HC4),
                                 .HC5(HC5),
                                 .HC6(HC6),
                                 .M1(M1),
                                 .M2(M2),
                                 .M3(M3),
                                 );
                                 
        ctrl            ctrl0(.clk(clk),
                              .reset(reset),
                              .gray_valid(gray_valid),
                              .comp_done(comp_done),
                              .comb_done(comb_done),
                              .split_done(split_done),
                              .order_done(order_done),
                              .comp_en(comp_en),
                              .comb_en(comb_en),
                              .order_en(order_en),
                              .split_en(split_en),
                              .out_en(out_en),
                              .CNT_valid(CNT_valid)
                              );

endmodule

