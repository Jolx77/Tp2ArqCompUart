module top #(
    parameter N = 8,
    parameter COUNT_TICKS = 16
)(
    input wire clk,
    input wire reset,
    input wire rx,
    output wire tx,
    output wire [N-1:0] data_out,
    output wire [N-1:0]alu_output
);

    // Señales internas
    wire tick;
    wire [N-1:0] data_rx;
    wire [N-1:0] data_tx;
    wire rx_valid, tx_start, tx_done;
    wire [N-1:0] alu_result;
    wire [N-1:0] o_A, o_B, o_op;
    wire start;
    //wire[N-1:0] alu_output;

    // UART Receiver
    uart_rx #(
        .N(N),
        .COUNT_TICKS(COUNT_TICKS)
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
        .COUNT_TICKS(COUNT_TICKS)
    ) uart_transmitter (
        .tick(tick),
        .clk(clk),
        .reset(reset),
        .tx_start(tx_start),
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
        //.state_output(state_output_w)
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
    assign alu_output = alu_result;
endmodule
