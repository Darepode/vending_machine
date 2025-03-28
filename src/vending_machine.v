// `include "control.v"                                                                                                                                                                                              
// `include "output_handler.v"
module vending_machine(
input clk,
input reset_n,
input start,
input done_money,
input cancel,
input continue_buy,
input [1:0] item_in,
input [2:0] money,
output done,
output [3:0] item_out,
output [7:0] change);

wire done_temp;
wire end_trans;
wire [7:0] sum_money;
wire [7:0] price;
wire [1:0] item_select;

control U1 (    .clk(clk),
                .reset_n(reset_n),
                .start(start),
                .done_money(done_money),
                .cancel(cancel),
                .continue_buy(continue_buy),
                .money(money),
                .item_in(item_in),
                .done(done_temp),
                .end_trans(end_trans),
                .sum_money(sum_money),
                .price(price),
                .item_select(item_select));
output_handler U2 (     .end_trans(end_trans),
                        .sum_money(sum_money),
                        .price(price),
                        .item_select(item_select),
                        .item_1(item_out[0]),
                        .item_2(item_out[1]),
                        .item_3(item_out[2]),
                        .item_4(item_out[3]),
                        .change(change));
assign done = done_temp ^ item_out[0] ^ item_out[1] ^ item_out[2] ^ item_out[3];

endmodule