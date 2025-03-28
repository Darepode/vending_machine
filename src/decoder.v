module decoder (                                                                                                                                                                                                   
input end_trans,
input [1:0] item_select,
output reg item_1,
output reg item_2,
output reg item_3,
output reg item_4);

always@(*)
begin
if(end_trans)
begin
        item_1 = 1'b0;
        item_2 = 1'b0;
        item_3 = 1'b0;
        item_4 = 1'b0;
end
else
begin
        case(item_select)
                2'b00:  begin
                        item_1 = 1'b1;
                        item_2 = 1'b0;
                        item_3 = 1'b0;
                        item_4 = 1'b0;
                        end
                2'b01:  begin
                        item_1 = 1'b0;
                        item_2 = 1'b1;
                        item_3 = 1'b0;
                        item_4 = 1'b0;
                        end
                2'b10:  begin
                        item_1 = 1'b0;
                        item_2 = 1'b0;
                        item_3 = 1'b1;
                        item_4 = 1'b0;
                        end
        default:        begin
                        item_1 = 1'b0;
                        item_2 = 1'b0;
                        item_3 = 1'b0;
                        item_4 = 1'b1;
                        end
        endcase
end
end
endmodule