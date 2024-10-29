module interface #(
    parameter N = 8,
    parameter A = 8'h1,
    parameter B = 8'h2,
    parameter OP = 8'h3,
    parameter R = 8'h4
)
(
    input wire [N-1:0] i_data_rx,
    input wire [N-1:0] i_data_tx,
    input wire i_rx_valid,
    input wire i_tx_done,
    input wire rst,
    input wire clk,
    output wire [N-1:0] o_A,
    output wire [N-1:0] o_B,
    output wire [N-1:0] o_op,
    output wire [N-1:0] o_tx,
    output wire o_tx_start 
);

    reg [N-1:0] reg_A, reg_B, reg_op, o_A_reg, o_B_reg, o_op_reg, o_tx_reg;
    reg check_A, check_B, check_OP;

    reg o_tx_start_reg;

    localparam [2:0] IDLE = 3'b000, 
                     WAIT_A = 3'b001, 
                     WAIT_B = 3'b010, 
                     WAIT_OP = 3'b011,
                     CHECK_REG = 3'b100,
                     TX_RESULT = 3'b101;

    reg [2:0] state = IDLE; 
    reg [2:0] next_state;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            o_A_reg <= 0;
            o_B_reg <= 0;
            o_op_reg <= 0;
        end
        else begin 
            state <= next_state;
            o_A_reg <= reg_A;
            o_B_reg <= reg_B;
            o_op_reg <= reg_op;
        end
    end 

    always @(*) begin
        next_state = state;
        case (state) 
            IDLE: begin
                o_tx_start_reg = 0;
                if (i_rx_valid) begin
                    case (i_data_rx)
                        A: next_state = WAIT_A;
                        B: next_state = WAIT_B;
                        OP: next_state = WAIT_OP;
                        R: next_state = CHECK_REG;
                        default: next_state = IDLE;
                    endcase
                end
            end
            WAIT_A: begin
                if (i_rx_valid == 1) begin
                    reg_A = i_data_rx;
                    check_A = 1;
                    next_state = IDLE;
                end
            end
            WAIT_B: begin
                if (i_rx_valid) begin
                    reg_B = i_data_rx;
                    check_B = 1;
                    next_state = IDLE;
                end
            end
            WAIT_OP: begin
                if (i_rx_valid) begin
                    reg_op = i_data_rx;
                    check_OP = 1;
                    next_state = IDLE;
                end
            end
            CHECK_REG: begin
                if (check_A && check_B && check_OP) begin
                    o_tx_reg = i_data_tx;
                    o_tx_start_reg = 1;
                    next_state = TX_RESULT;
                end
                else begin
                    next_state = IDLE;
                end
            end
            TX_RESULT: begin
                if (i_tx_done) begin
                    o_tx_start_reg = 0;
                    next_state = IDLE;
                end
            end
        endcase
    end
    assign o_A = o_A_reg;
    assign o_B = o_B_reg;
    assign o_op = o_op_reg;
    assign o_tx = o_tx_reg;
    assign o_tx_start = o_tx_start_reg;
endmodule
