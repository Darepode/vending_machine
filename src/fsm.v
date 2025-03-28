module fsm (                                                                                                                                                                                                       
input reset_n,
input start,
input done_money,
input cancel,
input continue_buy,
input deno_5,
input deno_10,
input deno_20,
input [1:0] item_in,
input clk,
output [4:0] sum_money,
output [4:0] price,
output reg [2:0] state);

parameter IDLE = 3'd0;
parameter SELECT = 3'd1;
parameter RECEIVE_MONEY = 3'd2;
parameter COMPARE = 3'd3;
parameter PROCESS = 3'd4;
parameter RETURN_CHANGE = 3'd5;

wire [2:0] money_1;
wire [3:0] money_2;
wire [4:0] money_3;
reg [2:0] next_state;
wire out_stock;
wire [2:0] nop [3:0];
wire [4:0] max_money;
wire [4:0] sum;
//reg [4:0] sum;
wire [4:0] pop [3:0];

//ASSIGN FOR TB
reg [4:0] sum_tb;

assign pop[0] = 5'd15;
assign pop[1] = 5'd31;
assign pop[2] = 5'd7;
assign pop[3] = 5'd21;

assign nop[0] = 3'd7;
assign nop[1] = 3'd5;
assign nop[2] = 3'd3;
assign nop[3] = 3'd0; 

assign sum = money_1 + money_2 + money_3;
assign out_stock = 1'b0;//(nop[item_in] == 0) ? 1'b1 : 1'b0;
assign money_1 = (deno_5) ? 3'd7 : 3'd0;
assign money_2 = (deno_10) ? 4'd15 : 4'd0;
assign money_3 = (deno_20) ? 5'd31 : 5'd0;
assign max_money = 5'b11111;
assign enough_money = (pop[item_in] <= sum) ? 1 : 0;
assign sum_money = sum;
assign price = pop[item_in];

always@(*)
begin
        case (state)
        IDLE: next_state = (start) ? SELECT : state;
        SELECT: next_state = ((~out_stock) && (~cancel)) ? RECEIVE_MONEY : ((out_stock) && (~cancel)) ? state : IDLE;
   //     RECEIVE_MONEY: next_state = ((done_money) || (sum > max_money) && (~cancel)) ? COMPARE : ((~done_money) && (sum < max_money) && (~cancel)) ? state : RETURN_CHANGE;
        RECEIVE_MONEY: next_state = (cancel) ? RETURN_CHANGE : (done_money || (sum > max_money)) ? COMPARE : RECEIVE_MONEY;
        //RECEIVE_MONEY: next_state = ((done_money) || (sum_tb > max_money) && (~cancel)) ? COMPARE : ((~done_money) && (sum < max_money) && (~cancel)) ? state : RETURN_CHANGE;
        COMPARE: next_state = (enough_money) ? RETURN_CHANGE : PROCESS;
        PROCESS: next_state = (cancel) ? RETURN_CHANGE : RECEIVE_MONEY;
        RETURN_CHANGE: next_state = (continue_buy) ? SELECT : IDLE;
        default: next_state = state;
        endcase
end

always@(posedge clk or negedge reset_n)
begin
        if(!reset_n) begin
                state <= IDLE;
       //         sum <= 5'b00000;
        end
        else begin
                state <= next_state;
       //         sum <= sum + 
        end
end
endmodule        