module uart_tx #(
    parameter N = 8,  // Number of data bits
    parameter M = 1,  // Number of stop bits
    parameter PARITY_EN = 0,  // Enable parity bit (0: disable, 1: enable)
    parameter BAUD_RATE = 9600,  // Baud rate
    parameter CLK_FREQ = 100000000,  // Clock frequency
    parameter COUNT_TICKS = 16
)(
    input wire tick,
    input wire clk,
    input wire reset,
    input wire start_tx,
    input wire [N-1:0] data_in,
    output wire tx,
    output wire tx_done
);

    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer baud_counter_WIDTH = $clog2(CYCLES_PER_BIT);

    reg [baud_counter_WIDTH-1:0] baud_counter, baud_counter_reg; //counts for tick

    localparam integer BIT_COUNTER_WIDTH = $clog2(N + M + PARITY_EN);

    // State definitions
    localparam [2:0] IDLE = 000,
                    START = 001,
                    DATA = 010,
                    PARITY = 011,
                    STOP = 100;
    


    reg[2:0] state = IDLE;
    reg[2:0] next_state;

    reg tx_done_reg;
    reg tx_reg;

    // Shift register
    reg [N-1:0] shift_reg;
    reg [BIT_COUNTER_WIDTH-1:0] bit_counter;

    // Parity bit
    reg parity_bit, parity_bit_reg;

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            parity_bit <= 0;
            baud_counter <= 0;
        end else begin
            state <= next_state;
            parity_bit <= parity_bit_reg;
           /* case (state)
                START, DATA, PARITY, STOP: begin
                    if(baud_counter_reg == 1) begin
                        baud_counter <= 0;
                    end else begin
                        baud_counter <= baud_counter + 1;
                    end
                end
                default: begin
                    baud_counter <= 0;
                    //bit_counter <= 0;
                end
            endcase*/
        end
    end

    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                baud_counter_reg = 0;
                tx_reg = 1;
                tx_done_reg = 0;
                shift_reg = 0;
                bit_counter = 0;
                if (start_tx) begin
                    next_state = START;
                    shift_reg = data_in;
                    parity_bit_reg = ^data_in;  // Calculate parity bit
                    
                end
            end
            START: begin
                if(tick) begin
                    tx_reg = 0;  // Start bit
                    if (baud_counter_reg == (COUNT_TICKS - 1)) begin
                        baud_counter_reg = 0;
                        next_state = DATA;
                    end
                    else begin
                        baud_counter_reg = baud_counter_reg + 1;
                    end
                end
            end
            DATA: begin
                if(tick) begin
                    //baud_counter_reg = 0;
                    if (baud_counter_reg == (COUNT_TICKS - 1)) begin
                        baud_counter_reg = 0;
                        shift_reg = shift_reg >> 1;
                        tx_reg = shift_reg[0];
                        bit_counter = bit_counter + 1;
                        if (bit_counter == N-1) begin
                            if (PARITY_EN) begin
                                next_state = PARITY;
                            end else begin
                                next_state = STOP;
                            end
                        end
                    end
                    else begin
                        baud_counter_reg = baud_counter_reg + 1;
                    end
                end
            end
            PARITY: begin
                if(tick) begin
                    //baud_counter_reg = 0;
                    if (baud_counter_reg == (COUNT_TICKS - 1)) begin
                        baud_counter_reg = 0;
                        tx_reg = parity_bit;
                        next_state = STOP;
                    end
                    else begin
                        baud_counter_reg = baud_counter_reg + 1;
                    end
                end
            end
            STOP: begin
                //baud_counter_reg = 0;
                if(tick) begin
                    if (baud_counter_reg == (COUNT_TICKS - 1)) begin
                        baud_counter_reg = 0;
                        tx_reg = 1;  // Stop bit
                        bit_counter = bit_counter + 1;
                        if (bit_counter >= N + M + PARITY_EN) begin
                            next_state = IDLE;
                            tx_done_reg = 1;
                        end
                    end
                    else begin
                        baud_counter_reg = baud_counter_reg + 1;
                    end
                end
            end
        endcase
    end 

    assign tx_done = tx_done_reg;
    assign tx = tx_reg;

endmodule