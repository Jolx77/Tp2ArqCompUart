module baudrate_generator #(
    parameter BAUD_RATE = 9600,
    parameter CLK_FREQ = 50000000,
    parameter COUNT = 326
)(
    input wire clk,
    input wire reset,
    output wire tick
);

    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;
    localparam integer TICK_COUNTER_WIDTH = $clog2(CYCLES_PER_BIT);

    reg [TICK_COUNTER_WIDTH-1:0] tick_counter;
    reg tick_reg;

    always @(posedge clk) begin
        if (reset) begin
            tick_counter <= 0;
            tick_reg <= 0;
        end else begin
            if (tick_counter == COUNT - 1) begin
                tick_counter <= 0;
                tick_reg <= 1;
            end else begin
                tick_counter <= tick_counter + 1;
                tick_reg <= 0;
            end
        end
    end

    assign tick = tick_reg;

endmodule