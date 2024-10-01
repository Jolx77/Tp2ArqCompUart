module uart_rx #(
    parameter N = 8,  // Number of data bits
    parameter M = 1,  // Number of stop bits
    parameter PARITY_EN = 0,  // Enable parity bit (0: disable, 1: enable)
    parameter BAUD_RATE = 9600,  // Baud rate
    parameter CLK_FREQ = 50000000  // Clock frequency
)(
    input wire tick,
    input wire reset,
    input wire clk,
    input wire rx,
    output reg [N-1:0] data_out,
    output reg valid
);

    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;

    localparam integer baud_counter_WIDTH = $clog2(CYCLES_PER_BIT);

    localparam [2:0] IDLE = 000,
                    START = 001,
                    DATA = 010,
                    PARITY = 011,
                    STOP = 100;
    


    reg[2:0] state = IDLE;
    reg[2:0] next_state;

    // Shift register
    reg [N-1:0] shift_reg;
    reg [baud_counter_WIDTH-1:0] baud_counter;

    integer bit_counter;

    // State machine
    always @(posedge reset or posedge clk) begin
        if (reset) begin
            state <= IDLE;
            baud_counter <= 0;
            bit_counter <= 0;
            shift_reg <= 0;
            valid <= 0;
            data_out <= 0;
        end else if(clk) begin
            state <= next_state;
            case (state)
                START, DATA, PARITY, STOP: begin
                    baud_counter <= baud_counter + 1;
                end
                default: begin
                    baud_counter <= 0;
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
                if (baud_counter == ((CYCLES_PER_BIT / 2) - 1)) begin
                    baud_counter = 0;
                    next_state = DATA;
                end
            end
            DATA: begin
                if (baud_counter == (CYCLES_PER_BIT - 1)) begin
                    shift_reg = {rx, shift_reg[N-1:1]};
                    bit_counter = bit_counter + 1;
                    baud_counter = 0;
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
                if (baud_counter == (CYCLES_PER_BIT - 1)) begin
                    // Handle parity bit if needed
                    baud_counter = 0;
                    next_state = STOP;
                end
            end
            STOP: begin
                if (baud_counter == (CYCLES_PER_BIT - 1)) begin
                    bit_counter = bit_counter + 1;
                    baud_counter = 0;
                    if (bit_counter == N + M + PARITY_EN) begin
                        shift_reg = {0, shift_reg[N-1:1]};
                        next_state = IDLE;
                        data_out = shift_reg;
                        valid = 1;
                    end
                end
            end
        endcase
    end

endmodule