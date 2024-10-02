module interface #(
    parameter N = 8,
    parameter A = 8'h1,
    parameter B = 8'h2,
    parameter OP = 8'h3,
    parameter R = 8'h4
)
(
    input i_data_rx[N-1:0],
    input i_rx_valid,
    input i_tx_done,
    input rst,
    input clk,
    output o_A[N-1:0],
    output o_B[N-1:0],
    output o_op[N-1:0],
    output o_tx[N-1:0],
    output o_tx_start 
);

    reg [N-1:0] reg_A, reg_B, reg_op;
    reg check_A, check_B, check_OP;

    localparam [2:0] IDLE = 000, 
                     WAIT_A = 001, 
                     WAIT_B = 010, 
                     WAIT_OP = 011,
                     CHECK_REG = 100;

    reg [2:0] state = IDLE; 
    reg [2:0] next_state;

    always @(posedge clk) begin
        if(rst)begin
            state <= IDLE;
            o_A <= 0;
            o_B <= 0;
            o_op <= 0;
            o_tx <= 0;
            o_tx_start <= 0;
        end
        else begin 
            state <= next_state;
        end
    end 

    always @(*) begin
        case(state) 
            IDLE: begin
               if(i_rx_valid == 1) begin
                case(i_data_rx)
                    A: begin
                        next_state = WAIT_A;
                    end
                    B: begin
                        next_state = WAIT_B;
                    end
                    OP: begin
                        next_state = WAIT_OP;
                    end
                    R: begin
                        next_state = CHECK_REG;
                    end
                endcase
               end
            end
            WAIT_A: begin
                if(i_rx_valid == 1) begin
                    reg_A = i_data_rx;
                    check_A = 1;
                    next_state = IDLE;
                end
            end
            WAIT_B: begin
                if(i_rx_valid == 1) begin
                    reg_B = i_data_rx;
                    check_B = 1;
                    next_state = IDLE;
                end
            end
            WAIT_OP: begin
                if(i_rx_valid == 1) begin
                    reg_op = i_data_rx;
                    check_OP = 1;
                    next_state = IDLE;
                end
            end
            CHECK_REG: begin
                if(check_A and check_B and check_OP) begin
                    reg_op = i_data_rx;
                    check_OP = 1;
                    next_state = IDLE;
                end
            end
        endcase
    end


endmodule