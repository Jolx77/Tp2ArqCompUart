module uart_tx #(
    parameter N = 8,  // Number of data bits
    parameter M = 1,  // Number of stop bits
    parameter PARITY_EN = 0,  // Enable parity bit (0: disable, 1: enable)
    parameter BAUD_RATE = 9600,  // Baud rate
    parameter CLK_FREQ = 50000000  // Clock frequency
)(
    input wire clk,
    input wire reset,
    input wire start_tx,
    input wire [N-1:0] data_in,
    output reg tx,
    output reg busy
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
    localparam [2:0] IDLE = 000,
                    START = 001,
                    DATA = 010,
                    PARITY = 011,
                    STOP = 100;
    


    reg[2:0] state = IDLE;
    reg[2:0] next_state;

    // Shift register
    reg [N-1:0] shift_reg;
    reg [BIT_COUNTER_WIDTH-1:0] bit_counter;

    // Parity bit
    reg parity_bit;

    // State machine
    always @(posedge tick or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            bit_counter <= 0;
            shift_reg <= 0;
            parity_bit <= 0;
            tx <= 1;
            busy <= 0;
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
                if (start_tx) begin
                    next_state = START;
                    shift_reg = data_in;
                    parity_bit = ^data_in;  // Calculate parity bit
                    busy = 1;
                end
            end
            START: begin
                if (tick) begin
                    next_state = DATA;
                    tx = 0;  // Start bit
                end
            end
            DATA: begin
                if (tick) begin
                    tx = shift_reg[0];
                    shift_reg = shift_reg >> 1;
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
                if (tick) begin
                    tx = parity_bit;
                    next_state = STOP;
                end
            end
            STOP: begin
                if (tick) begin
                    tx = 1;  // Stop bit
                    if (bit_counter == M) begin
                        next_state = IDLE;
                        busy = 0;
                    end
                end
            end
        endcase
    end

endmodule