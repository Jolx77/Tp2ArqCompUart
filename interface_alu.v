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
    output reg [N-1:0] o_A,
    output reg [N-1:0] o_B,
    output reg [N-1:0] o_op,
    output reg [N-1:0] o_tx,
    output reg o_tx_start 
);

    reg [N-1:0] reg_A, reg_B, reg_op;
    reg check_A, check_B, check_OP;

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
            o_A <= 0;
            o_B <= 0;
            o_op <= 0;
            o_tx <= 0;
            o_tx_start <= 0;
            reg_A <= 0;
            reg_B <= 0;
            reg_op <= 0;
            check_A <= 0;
            check_B <= 0;
            check_OP <= 0;
        end
        else begin 
            state <= next_state;
        end
    end 

    always @(*) begin
        next_state = state;
        case (state) 
            IDLE: begin
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
                    o_tx = i_data_tx;
                    o_tx_start = 1;
                    next_state = TX_RESULT;
                end
                else begin
                    next_state = IDLE;
                end
            end
            TX_RESULT: begin
                if (i_tx_done) begin
                    o_tx_start = 0;
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Asignaciones de salida de los registros
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            o_A <= 0;
            o_B <= 0;
            o_op <= 0;
        end else begin
            o_A <= reg_A;
            o_B <= reg_B;
            o_op <= reg_op;
        end
    end

endmodule
