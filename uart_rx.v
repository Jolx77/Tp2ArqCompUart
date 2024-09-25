module uart_rx #(
    parameter N = 8,  // Number of data bits
    parameter M = 1,  // Number of stop bits
    parameter PARITY_EN = 0,  // Enable parity bit (0: disable, 1: enable)
    parameter BAUD_RATE = 9600,  // Baud rate
    parameter CLK_FREQ = 50000000  // Clock frequency
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output reg [N-1:0] data_out,
    output reg valid
);

    // Instantiate baudrate generator
    wire tick;
    baudrate_generator #(
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) baud_gen (
        .clk(clk),
        .reset(reset),
        .tick(tick)
    );

    localparam integer BIT_COUNTER_WIDTH = $clog2(N + M + PARITY_EN);

    // State definitions
    typedef enum reg [2:0] {
        IDLE,
        START,
        DATA,
        PARITY,
        STOP
    } state_t;

    state_t state, next_state;

    // Shift register
    reg [N-1:0] shift_reg;
    reg [BIT_COUNTER_WIDTH-1:0] bit_counter;

    // State machine
    always @(posedge tick or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            shift_reg <= 0;
            valid <= 0;
        end else begin
            state <= next_state;
            case (state)
                START, DATA, PARITY, STOP: begin
                    bit_counter <= bit_counter + 1;
                end
                default: begin
                    bit_counter <= 0;
                end
            endcase
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (rx == 0) begin
                    next_state = START;
                end
            end
            START: begin
                if (bit_counter == (CYCLES_PER_BIT / 2 - 1)) begin
                    next_state = DATA;
                end
            end
            DATA: begin
                if (bit_counter == (CYCLES_PER_BIT - 1)) begin
                    shift_reg = {rx, shift_reg[N-1:1]};
                    if (bit_counter == N-1) begin
                        if (PARITY_EN) begin
                            next_state = PARITY;
                        end else begin
                            next_state = STOP;
                        end
                    end
                end
            end
            PARITY: begin
                if (bit_counter == (CYCLES_PER_BIT - 1)) begin
                    // Handle parity bit if needed
                    next_state = STOP;
                end
            end
            STOP: begin
                if (bit_counter == (CYCLES_PER_BIT - 1)) begin
                    if (bit_counter == M) begin
                        next_state = IDLE;
                        data_out = shift_reg;
                        valid = 1;
                    end
                end
            end
        endcase
    end

endmodule