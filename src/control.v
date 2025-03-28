// `include "output_loic.v"
// `include "fsm.v"
module control (                                                                                                                                                                                                   
input clk,
input reset_n,
input start,
input done_money,
input cancel,
input continue_buy,
input [2:0] money,
input [1:0] item_in,
output done,
output end_trans,
output [7:0] sum_money,
output [7:0] price,
output [1:0] item_select);

wire [4:0] sum_money_temp;
wire [4:0] price_temp;
wire [2:0] state;
wire [1:0] item_temp;

fsm U1 (.clk(clk),
        .reset_n(reset_n),
        .start(start),
        .done_money(done_money),
        .cancel(cancel),
        .continue_buy(continue_buy),
        .deno_5(money[0]),
        .deno_10(money[1]),
        .deno_20(money[2]),
        .item_in(item_temp),
        .state(state),
        .sum_money(sum_money_temp),
        .price(price_temp));
output_loic U2  (
        .state(state),
        .pop(price_temp),
        .money(sum_money_temp),
        .item(item_temp),
        .done(done),
        .end_trans(end_trans),
        .sum_money(sum_money),
        .price(price),
        .item_select(item_select)
        );
endmodule