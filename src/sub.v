module sub (                                                                                                                                                                                                       
input end_trans,
input [7:0] sum_money,
input [7:0] price,
output [7:0] change);
assign change = (end_trans) ? (sum_money - price ) : 8'b00000000;
endmodule