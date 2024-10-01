`timescale 1ns / 1ps

module uart_rx_tb;

    // Parameters
    parameter N = 8;
    parameter M = 1;
    parameter PARITY_EN = 0;
    parameter BAUD_RATE = 9600;
    parameter CLK_FREQ = 50000000;

    // Clock period
    integer CLK_PERIOD = 20;  // 50 MHz clock

    // Calculate baud period
    localparam integer BAUD_PERIOD = (1 / BAUD_RATE)/1000000000;

    // Signals
    reg clk;
    reg reset;
    reg rx;
    wire [N-1:0] data_out;
    wire valid;
    wire tick;

    // Instantiate uart_rx
    uart_rx #(
        .N(N),
        .M(M),
        .PARITY_EN(PARITY_EN),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uut (
        .clk(clk),
        //.tick(tick),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .valid(valid)
    );

    baudrate_generator baudrate_gen(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    ) ;

    // Clock generation
    initial begin
        clk = 0;
        forever #(CLK_PERIOD / 2) clk = ~clk;
    end

    // Test sequence
    initial begin
        // Initialize signals
        reset = 1;
        rx = 1;

        // Apply reset
        #(10 * CLK_PERIOD);
        reset = 0;

        // Wait for a few clock cycles
        #(10 * CLK_PERIOD);

        // Simulate receiving a byte (0x55 = 01010101)
        //rx = 0;
        send_byte(8'h15);
        send_byte(8'h11);

        // Wait for the byte to be received
        #(300 * CLK_PERIOD);

        // Simulate receiving another byte (0xAA = 10101010)
        //send_byte(8'hAA);

        // Wait for the byte to be received
        #(200 * CLK_PERIOD);

        // Finish simulation
        #(50005 * CLK_PERIOD);
        $finish;
    end

    // Task to send a byte
    task send_byte(input [7:0] byte);
        integer i;
        begin
            // Start bit
            rx = 0;
            //#(BAUD_PERIOD);
            @(posedge tick);

            // Data bits
            for (i = 0; i < N; i = i + 1) begin
                rx = byte[i];
                //#(BAUD_PERIOD);
                @(posedge tick);
            end

            // Stop bit
            rx = 1;
            //#(BAUD_PERIOD);
            @(posedge tick);
        end
    endtask

endmodule