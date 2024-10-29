module top_t #(
    parameter N = 8,
    parameter CLK_FREQ = 50000000,
    parameter BAUD_RATE = 9600
)(
    input wire [N-1:0]i_data_rx,
    input wire i_c,
    input wire clk,
    input wire reset,
    //input wire rx,
    output wire tx
);

    localparam integer CYCLES_PER_BIT = CLK_FREQ / BAUD_RATE;

    // Señales internas
    wire [N-1:0] data_rx;
    wire [N-1:0] data_tx;
    wire rx_valid, tx_start, tx_done;
    wire [N-1:0] alu_result;
    wire [N-1:0] o_A, o_B, o_op;
    wire rx;
    reg tx_start2;
    wire tx_done2; 
    reg [N-1:0]i_data_rx2;
    //wire rx_i_aux[N-1:0];

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

    uart_tx #(
        .N(N),
        .BAUD_RATE(BAUD_RATE),
        .CLK_FREQ(CLK_FREQ)
    ) uart_transmitter2 (
        .clk(clk),
        .reset(reset),
        .start_tx(tx_start2),
        .data_in(i_data_rx2),
        .tx(rx),
        .tx_done(tx_done2)
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

    baudrate_generator baudrate_gen(
        .clk(clk),
        .reset(reset),
        .tick(tick)
    ) ;

    integer c_triggered;


    always @(posedge clk) begin
        if(i_c == 1 && c_triggered == 0)begin
            i_data_rx2 = i_data_rx;
            tx_start2 = 1;
            c_triggered = 1;
        end
        else if(tx_done2 == 1) begin
            c_triggered = 0;
        end
    end
    //assign rx_i_aux = i_data_rx;


endmodule
