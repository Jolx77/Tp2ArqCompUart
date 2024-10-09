module top #(
    parameter N = 8,
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx
);

    // Señales internas
    wire [N-1:0] data_rx;
    wire [N-1:0] data_tx;
    wire rx_valid, tx_start, tx_done;
    wire [N-1:0] alu_result;
    wire [N-1:0] o_A, o_B, o_op;

    // UART Receiver
    uart_rx #(
        .N(N),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_receiver (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_rx),
        .valid(rx_valid)
    );

    // UART Transmitter
    uart_tx #(
        .N(N),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_transmitter (
        .clk(clk),
        .reset(reset),
        .start_tx(tx_start),
        .data_in(data_tx),
        .tx(tx),
        .tx_done(tx_done)
    );

    // Interfaz
    interface #(
        .N(N)
    ) interface_inst (
        .i_data_rx(data_rx),
        .i_data_tx(alu_result),
        .i_rx_valid(rx_valid),
        .i_tx_done(tx_done),
        .rst(reset),
        .clk(clk),
        .o_A(o_A),
        .o_B(o_B),
        .o_op(o_op),
        .o_tx(data_tx),
        .o_tx_start(tx_start)
    );

    // ALU
    ALU #(
        .DATA_WIDTH(N)
    ) alu_inst (
        .i_A(o_A),
        .i_B(o_B),
        .i_mode(o_op),
        .o_result(alu_result)
    );

endmodule
