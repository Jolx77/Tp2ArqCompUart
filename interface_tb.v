module interface_tb;

    // Parámetros
    localparam N = 8;
    localparam A = 8'h1;
    localparam B = 8'h2;
    localparam OP = 8'h3;
    localparam R = 8'h4;

    // Señales
    reg [N-1:0] i_data_rx;
    reg [N-1:0] i_data_tx;
    reg i_rx_valid;
    reg i_tx_done;
    reg rst;
    reg clk;
    wire [N-1:0] o_A;
    wire [N-1:0] o_B;
    wire [N-1:0] o_op;
    wire [N-1:0] o_tx;
    wire o_tx_start;

    // Instancia del módulo
    interface #(
        .N(N),
        .A(A),
        .B(B),
        .OP(OP),
        .R(R)
    ) uut (
        .i_data_rx(i_data_rx),
        .i_data_tx(i_data_tx),
        .i_rx_valid(i_rx_valid),
        .i_tx_done(i_tx_done),
        .rst(rst),
        .clk(clk),
        .o_A(o_A),
        .o_B(o_B),
        .o_op(o_op),
        .o_tx(o_tx),
        .o_tx_start(o_tx_start)
    );

    // Generación del clock
    always #5 clk = ~clk; // Clock de 100 MHz

    initial begin
        // Inicialización
        clk = 0;
        rst = 1;
        i_rx_valid = 0;
        i_tx_done = 0;
        i_data_rx = 0;
        i_data_tx = 8'hAA; // Dato de ejemplo para transmitir

        // Reset
        #20;
        rst = 0;

        // Envío de la señal A
        #10;
        i_data_rx = A;
        i_rx_valid = 1;
        #5;
        i_rx_valid = 0;

        // Envío del valor para A
        #20;
        i_data_rx = 8'h10;
        i_rx_valid = 1;
        #5;
        i_rx_valid = 0;

        // Envío de la señal B
        #20;
        i_data_rx = B;
        i_rx_valid = 1;
        #10;
        i_rx_valid = 0;

        // Envío del valor para B
        #20;
        i_data_rx = 8'h20;
        i_rx_valid = 1;
        #10;
        i_rx_valid = 0;

        // Envío de la señal OP
        #20;
        i_data_rx = OP;
        i_rx_valid = 1;
        #10;
        i_rx_valid = 0;

        // Envío del valor para OP
        #20;
        i_data_rx = 8'h02;
        i_rx_valid = 1;
        #10;
        i_rx_valid = 0;

        // Envío de la señal R para transmitir el resultado
        #20;
        i_data_rx = R;
        i_rx_valid = 1;
        #10;
        i_rx_valid = 0;

        // Simulación de transmisión completada
        #30;
        i_tx_done = 1;
        #10;
        i_tx_done = 0;

        // Fin de la simulación
        #100;
        $finish;
    end

endmodule
