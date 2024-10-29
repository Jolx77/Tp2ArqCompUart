module top #(
    parameter N = 8,
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600,
    parameter COUNT_TICKS = 16,
    parameter PARITY_EN = 0
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx,
    output wire [N-1:0] data_out,
    output wire [2:0]state_rx,
    output wire started,
    output wire tick_o
    //output wire rx_led,
    //output wire tx_led
);

    // Señales internas
    wire tick;
    wire [N-1:0] data_rx;
    wire [N-1:0] data_tx;
    wire rx_valid, tx_start, tx_done;
    wire [N-1:0] alu_result;
    wire [N-1:0] o_A, o_B, o_op;

    // UART Receiver
    uart_rx #(
        .N(N),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .COUNT_TICKS(COUNT_TICKS),
        .PARITY_EN(PARITY_EN)
    ) uart_receiver (
        .state_leds(state_rx),
        .tick(tick),
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_rx),
        .valid(rx_valid),
        .started(started)
    );
    
    // UART Transmitter
    uart_tx #(
        .N(N),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ),
        .COUNT_TICKS(COUNT_TICKS),
        .PARITY_EN(PARITY_EN)
    ) uart_transmitter (
        .tick(tick),
        .clk(clk),
        .reset(reset),
        .start_tx(tx_start),
        .data_in(data_tx),
        .tx(tx),
        .tx_done(tx_done)
    );

    baudrate_generator baudrate_gen(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    ) ;

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

    assign data_out = data_rx;
    assign tick_o = tick;
    //assign rx_led = rx;
    //assign tx_led = tx;
endmodule
