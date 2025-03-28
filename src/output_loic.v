
module output_loic (                                                                                                                                                                                               
input [2:0] state,
input [4:0] pop,
input [4:0] money,
input [1:0] item,
output reg done,
output reg end_trans,
output reg [7:0] sum_money,
output reg [7:0] price,
output reg [1:0] item_select);

parameter IDLE = 3'd0;
parameter SELECT = 3'd1;
parameter RECEIVE_MONEY = 3'd2;
parameter COMPARE = 3'd3;
parameter PROCESS = 3'd4;
parameter RETURN_CHANGE = 3'd5;

// ASSIGN FIX VALUE FOR BUILDING TB
//assign sum_money = 36;

always@(*)
begin
        case (state)
        IDLE:
        begin
                done = 1'b0;
                end_trans = 1'b0;
                sum_money = 8'b00000000;
                price = 8'b00000000;
                item_select = 2'b00;
        end
        SELECT:
        begin
                done = 1'b0;
                end_trans = 1'b0;
                sum_money = 8'b00000000;
                price = 8'b00000000;
                item_select = 2'b00;
        end
        RECEIVE_MONEY:
        begin
                done = 1'b0;
                end_trans = 1'b0;
                sum_money = 8'b00000000;
                price = 8'b00000000;
                item_select = 2'b00;
        end
        COMPARE:                                                                                                                                                                                             
        begin
                done = 1'b0;
                end_trans = 1'b0;
                sum_money = 8'b00000000;                                                                                                                                                                           
                price = 8'b00000000;
                item_select = 2'b00;
        end
        PROCESS:                                                                                                                                                                                             
        begin
                done = 1'b0;
                end_trans = 1'b0;                                                                                                                                                                                  
                sum_money = 8'b00000000;                                                                                                                                                                           
                price = 8'b00000000;
                item_select = 2'b00;
        end
        RETURN_CHANGE:                                                                                                                                                                                             
        begin
                done = 1'b0;
                end_trans = 1'b1;                                                                                                                                                                                  
                sum_money = money;                                                                                                                                                                           
                price = pop;
                item_select = item;
        end
        default:
        begin
                done = 1'b0;
                end_trans = 1'b0;
                sum_money = 8'b00000000;                                                                                                                                                                           
                price = 8'b00000000;
                item_select = 2'b00;

        end
        endcase
end
endmodule      