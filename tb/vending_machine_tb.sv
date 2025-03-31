`timescale 1ns/1ps
module vending_machine_tb;

    // Input signals
    logic clk;
    logic reset_n;
    logic start;
    logic done_money;
    logic cancel;
    logic continue_buy;
    logic [2:0] money;
    logic [1:0] item_in;

    // Output signals
    logic       done;
    logic       end_trans;
    logic [7:0] sum_money;
    logic [7:0] price;
    logic [1:0] item_select;

    //Design Instantiation
    control dut (
        .clk          (clk),
        .reset_n      (reset_n),
        .start        (start),
        .done_money   (done_money),
        .cancel       (cancel),
        .continue_buy (continue_buy),
        .money        (money),
        .item_in      (item_in),
        .done         (done),
        .end_trans    (end_trans),
        .sum_money    (sum_money),
        .price        (price),
        .item_select  (item_select)
    );

    // Wave dump
    initial begin
        $dumpfile("vending_machine_tb.vcd");
        $dumpvars(0,vending_machine_tb);
    end

    //Clock Generation
    initial begin 
		clk = 1'b0;
	    forever #5 clk = ~clk;
	end

    parameter IDLE          = 3'd0;
    parameter SELECT        = 3'd1;
    parameter RECEIVE_MONEY = 3'd2;
    parameter COMPARE       = 3'd3;
    parameter PROCESS       = 3'd4;
    parameter RETURN_CHANGE = 3'd5;

    // Tasks    
    // Task to reset the vending machine
    task automatic reset_machine;
        begin
            reset_n = 0;
            start = 1'b0;
            done_money = 1'b0;
            cancel = 1'b0;
            continue_buy = 1'b0;
            money = 3'b000;
            item_in = 2'b00;
            #20
            if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 && dut.U1.next_state == 3'b000) begin
                $display("Reset Successfully ^^");
            //    $display("At %0.t | done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b", $time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
            end else
                $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
            #10 reset_n = 1;
        end
    endtask

    task automatic IDLE_check; 
        input bit start_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            start = start_ck;
            @(posedge clk);
            #3
            if (enable_check) begin
                if (!start_ck) begin
                    if (dut.U1.state == IDLE) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("IDLE --> IDLE  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                            $display("TRANSITION FAILED at %0.t ps - State should be IDLE", $time);
                end else begin
                if (start_ck) begin
                    if (dut.U1.state == SELECT) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("IDLE --> SELECT  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                        $display("TRANSITION FAILED at %0.t ps - State should be SELECT", $time);
                end
                end
            end
            start = 1'b0;           
        end
    endtask

    task automatic SELECT_check;
        input bit cancel_ck;
        input bit out_stock_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            cancel = cancel_ck;
            item_in = $urandom % 4;
            if (out_stock_ck)
                force dut.U1.out_stock = 3'd1;
            else
                force dut.U1.out_stock = 3'd0;
            @(posedge clk);
            #3
            if (enable_check) begin
                if (cancel_ck) begin
                    if (dut.U1.state == IDLE) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 )
                            $display("SELECT --> IDLE  => PASSED at %0.t ps", $time);
                        else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end 
                    else 
                        $display("TRANSITION FAILED at %0.t ps - State should be IDLE", $time);
                end 
                else
                if (!cancel_ck && dut.U1.out_stock) begin
                    if (dut.U1.state == SELECT) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 )
                            $display("SELECT --> SELECT  => PASSED at %0.t ps", $time);
                        else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end 
                    else
                        $display("TRANSITION FAILED at %0.t ps - State should be SELECT", $time);
                end
                else
                if (!cancel_ck && !dut.U1.out_stock) begin
                    @(negedge clk);
                    //#7
                    if (dut.U1.state == RECEIVE_MONEY) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 )
                            $display("SELECT --> RECEIVE_MONEY  => PASSED at %0.t ps", $time);
                        else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end 
                    else
                        $display("TRANSITION FAILED at %0.t ps - State should be RECEIVE_MONEY", $time);
                end
            end
            cancel = 1'b0;
            release dut.U1.out_stock;
        end
    endtask

    task automatic RECEIVE_MONEY_check;
        input bit cancel_ck;
        input bit done_money_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            cancel = 1'b0;
            money = $random % 8; // 7
            #3;
            @(negedge clk);
            money = $random % 8; // 15
            #3;
            done_money = done_money_ck;
            cancel = cancel_ck;
            @(posedge clk);
            #3
            if (enable_check) begin
                // Assign fixed value ((sum_money > 31) ? 1'b1 : 1'b0)
                case ({cancel,done_money,1'b0})
                    3'b000: begin
                        if (dut.U1.state == RECEIVE_MONEY) begin
                            if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 )
                                $display("RECEIVE_MONEY --> RECEIVE_MONEY  => PASSED at %0.t ps", $time);
                            else
                                $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                        end
                        else
                            $display("TRANSITION FAILED at %0.t ps - State should be RECEIVE_MONEY", $time);    
                    end
                    3'b001, 3'b010, 3'b011: begin
                        if (dut.U1.state == COMPARE) begin
                            if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 )
                                $display("RECEIVE_MONEY --> COMPARE  => PASSED at %0.t ps", $time);
                            else
                                $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                        end
                        else
                            $display("TRANSITION FAILED at %0.t ps - State should be COMPARE", $time);   
                    end
                    //=========================== MENTION THIS CASE - OUTPUTS OF STATE ===========================================
                    3'b100, 3'b101, 3'b110, 3'b111: begin
                        if (dut.U1.state == RETURN_CHANGE) begin
                            if(done == 1'b0 && end_trans == 1'b1 /*&& sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 */)
                                $display("RECEIVE_MONEY --> RETURN_CHANGE  => PASSED at %0.t ps", $time);
                            else
                                $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                        end
                        else begin
                            $display("TRANSITION FAILED at %0.t ps - State should be RETURN_CHANGE", $time);   
                        end
                    end
                    default: begin
                        $display("Hello World");
                        $display("At %0.t ps: cancel: %b | done_money: %b ",$time, cancel, done_money);
                    end
                endcase
            end
            cancel = 1'b0;
            done_money = 1'b0;
        end
    endtask

    task automatic COMPARE_check; 
        input bit enough_money_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            if (enough_money_ck)
                force dut.U1.enough_money = 3'd1;
            else
                force dut.U1.enough_money = 3'd0;
            @(posedge clk);
            #3
            if (enable_check) begin
                if (!dut.U1.enough_money) begin
                    if (dut.U1.state == PROCESS) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("COMPARE --> PROCESS  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                            $display("TRANSITION FAILED at %0.t ps - State should be PROCESS", $time);
                end else begin
                if (dut.U1.enough_money) begin
                    if (dut.U1.state == RETURN_CHANGE) begin
                        if(done == 1'b0 && end_trans == 1'b1 /*&& sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 */) begin
                            $display("COMPARE --> RETURN_CHANGE  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                        $display("TRANSITION FAILED at %0.t ps - State should be RETURN_CHANGE", $time);
                end
                end
            end
            release dut.U1.enough_money;         
        end
    endtask

    task automatic PROCESS_check; 
        input bit cancel_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            cancel = cancel_ck;
            @(posedge clk);
            #3
            if (enable_check) begin
                if (!cancel) begin
                    if (dut.U1.state == RECEIVE_MONEY) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("PROCESS --> RECEIVE_MONEY  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                            $display("TRANSITION FAILED at %0.t ps - State should be RECEIVE_MONEY", $time);
                end else begin
                if (cancel) begin
                    if (dut.U1.state == RETURN_CHANGE) begin
                        if(done == 1'b0 && end_trans == 1'b1 /*&& sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 */) begin
                            $display("PROCESS --> RETURN_CHANGE  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                        $display("TRANSITION FAILED at %0.t ps - State should be RETURN_CHANGE", $time);
                end
                end
            end
            cancel = 1'b0;           
        end
    endtask

    task automatic RETURN_CHANGE_check; 
        input bit continue_buy_ck;
        input bit enable_check;

        begin
            @(negedge clk);
            continue_buy = continue_buy_ck;
            @(posedge clk);
            #3
            if (enable_check) begin
                if (!continue_buy) begin
                    if (dut.U1.state == IDLE) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("RETURN_CHANGE --> IDLE  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %h | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                            $display("TRANSITION FAILED at %0.t ps - State should be IDLE", $time);
                end else begin
                if (continue_buy) begin
                    if (dut.U1.state == SELECT) begin
                        if(done == 1'b0 && end_trans == 1'b0 && sum_money == 8'h00 && price == 8'h00 && item_select == 2'b00 ) begin
                            $display("RETURN_CHANGE --> SELECT  => PASSED at %0.t ps", $time);
                        end else
                            $display("FAILED at %0.t ps: done: %b | end_trans: %b | sum_money: %b | price: %b | item_select: %b | next_state: %b",$time, done, end_trans, sum_money, price, item_select, dut.U1.next_state);
                    end else
                        $display("TRANSITION FAILED at %0.t ps - State should be SELECT", $time);
                end
                end
            end
            #3
            continue_buy = 1'b0;           
        end
    endtask

initial begin
    //$display("Time at %0.t ps", $time);
    $display("\n=================================================== Simulation ===================================================\n");
    reset_machine;
    #5
    $display("Checking at state IDLE with start = 0");
    IDLE_check(0,1);   // Check1
    $display("Checking at state IDLE with start = 1");
    IDLE_check(1,1);   // Check2
    //=========================================================================================================
    $display("\nChecking at state SELECT with cancel = 1");
    SELECT_check(1,0,1); //(cancel, out_stock, enable_check)    // Check3
    $display("Checking at state SELECT with cancel = 0 and out_stock = 1");
    IDLE_check(1,0);
    SELECT_check(0,1,1); //(cancel, out_stock, enable_check)    // Check4
    $display("Checking at state SELECT with cancel = 0 and out_stock = 0");
    SELECT_check(0,0,1); //(cancel, out_stock, enable_check)    // Check5
    //=========================================================================================================
    $display("\nChecking at state RECEIVE_MONEY with cancel = 0 and done_money = 0 and (sum > max_money) = 0");
    RECEIVE_MONEY_check(0,0,1); //(cancel, done_money, enable_check)         // Check6
    $display("Checking at state RECEIVE_MONEY with cancel = 0 and done_money = 1 and (sum > max_money) = 0");
    RECEIVE_MONEY_check(1'b0,1'b1,1);  //(cancel, done_money, enable_check)  // Check7
    //=========================================================================================================
    reset_machine;
    #5
    IDLE_check(1,0);
    SELECT_check(0,0,0);
    $display("Checking at state RECEIVE_MONEY with cancel = 1 and done_money = 0 and (sum > max_money) = 0");
    RECEIVE_MONEY_check(1'b1,1'b0,1);  //(cancel, done_money, enable_check)  // Check8
    //=========================================================================================================
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    $display("Checking at state RECEIVE_MONEY with cancel = 1 and done_money = 1 and (sum > max_money) = 0");
    RECEIVE_MONEY_check(1'b1,1'b1,1);  //(cancel, done_money, enable_check)  // Check9
    // Cannot cover cases where (sum > max_money) = 1
    //=========================================================================================================
    $write("\n");
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    RECEIVE_MONEY_check(1'b0,1'b1,0);  //(cancel, done_money, enable_check)  
    $display("Checking at state COMPARE with enough_money = 0");
    COMPARE_check(0,1);                                                      // Check10
    //=========================================================================================================
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    RECEIVE_MONEY_check(1'b0,1'b1,0);  //(cancel, done_money, enable_check)  
    $display("Checking at state COMPARE with enough_money = 1");
    COMPARE_check(1,1);                                                      // Check11
    //=========================================================================================================
    $write("\n");
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    RECEIVE_MONEY_check(1'b0,1'b1,0);  //(cancel, done_money, enable_check)  
    COMPARE_check(0,0);
    $display("Checking at state PROCESS with cancel = 0");
    PROCESS_check(0,1);                                                      // Check12
    //=========================================================================================================
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    RECEIVE_MONEY_check(1'b0,1'b1,0);  //(cancel, done_money, enable_check)  
    COMPARE_check(0,0);
    $display("Checking at state PROCESS with cancel = 0");
    PROCESS_check(1,1);                                                      // Check13
    //=========================================================================================================
    $display("\nChecking at state RETURN_CHANGE with continue_buy = 1");
    RETURN_CHANGE_check(1,1);                                                // Check14
    //=========================================================================================================
    reset_machine;
    #5
    IDLE_check(1,0);   
    SELECT_check(0,0,0);
    RECEIVE_MONEY_check(1'b1,1'b0,0);  //(cancel, done_money, enable_check)  
    $display("Checking at state RETURN_CHANGE with continue_buy = 0");
    RETURN_CHANGE_check(0,1);                                                // Check15
    
    #50
    $display("\n====================================================== End =======================================================");
    $finish();
end

endmodule
