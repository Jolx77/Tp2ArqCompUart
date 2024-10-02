/*
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

endmodule*/

module uart_tx_tb;

  // Parámetros del UART
  localparam N = 8;
  localparam M = 1;
  localparam PARITY_EN = 0;
  localparam BAUD_RATE = 9600;
  localparam CLK_FREQ = 50000000;

  // Señales del testbench
  reg clk;
  reg reset;
  reg start_tx;
  reg [N-1:0] data_in;
  wire tx;
  wire busy;

  // Instancia del módulo UART_TX
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

  // Generación de clock
  always #10 clk = ~clk;  // 50 MHz clock

  initial begin
    // Inicialización de señales
    clk = 0;
    reset = 0;
    start_tx = 0;
    data_in = 8'b00000000;

    // Reset del sistema
    reset = 1;
    #20;
    reset = 0;
    #20;

    // Prueba de transmisión de un byte de datos
    data_in = 8'b10101010;  // Dato a enviar
    start_tx = 1;
    #20;
    start_tx = 0;

    // Esperar hasta que el UART termine de transmitir
    wait (busy == 0);
    #500;  // Espera adicional para observar la transmisión completa

    // Prueba de transmisión de otro byte de datos
    data_in = 8'b11001100;  // Otro dato a enviar
    start_tx = 1;
    #20;
    start_tx = 0;

    wait (busy == 0);
    #100;

    // Final de la simulación
    $finish;
  end

endmodule

