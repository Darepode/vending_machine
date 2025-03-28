// `include "sub.v"
// `include "decoder.v"
module output_handler (
input end_trans,
input [7:0] sum_money,
input [7:0] price,
input [1:0] item_select,
output item_1,
output item_2,
output item_3,
output item_4,
output [7:0] change);
                                                                                                                                                                                                                   
decoder U1 (.end_trans(end_trans), .item_select(item_select), .item_1(item_1), .item_2(item_2), .item_3(item_3), .item_4(item_4));
sub     U2 (.end_trans(end_trans), .sum_money(sum_money), .price(price), .change(change));

endmodule