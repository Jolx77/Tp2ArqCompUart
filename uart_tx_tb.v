`timescale 1ns / 1ps

module uart_tx_tb;

    // Parameters
    parameter N = 8;
    parameter M = 1;
    parameter PARITY_EN = 0;
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000;

    // Clock period
    localparam CLK_PERIOD = 20;  // 50 MHz clock

    // Signals
    reg clk;
    reg reset;
    reg start_tx;
    reg [N-1:0] data_in;
    wire tx;
    wire busy;

    // Instantiate uart_tx
    uart_tx #(
        .N(N),
        .M(M),
        .PARITY_EN(PARITY_EN),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        .reset(reset),
        .start_tx(start_tx),
        .data_in(data_in),
        .tx(tx),
        .busy(busy)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        start_tx = 0;
        data_in = 8'h00;

        // Apply reset
        #(10 * CLK_PERIOD);
        reset = 0;

        // Wait for a few clock cycles
        #(10 * CLK_PERIOD);

        // Simulate transmitting a byte (0x55 = 01010101)
        data_in = 8'h55;
        start_tx = 1;
        #(CLK_PERIOD);
        start_tx = 0;

        // Wait for the byte to be transmitted
        #(100 * CLK_PERIOD);

        // Simulate transmitting another byte (0xAA = 10101010)
        data_in = 8'hAA;
        start_tx = 1;
        #(CLK_PERIOD);
        start_tx = 0;

        // Wait for the byte to be transmitted
        #(100 * CLK_PERIOD);

        // Finish simulation
        #(100 * CLK_PERIOD);
        $finish;
    end

endmodule