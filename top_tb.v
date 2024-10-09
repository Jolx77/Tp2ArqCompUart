module tb_top;

    // Parámetros
    parameter N = 8;
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    reg clk;
    reg reset;
    reg rx;
    wire tx;

    // Instancia del módulo top
    top #(
        .N(N),
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) uut (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .tx(tx)
    );

    // Reloj de 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Periodo de 20 ns, frecuencia de 50 MHz
    end

    // Generación de reset y estímulos
    initial begin
        reset = 1;
        rx = 1;  // Inicialmente en estado alto
        #100;
        reset = 0;

        // Envío de un dato 'A'
        send_byte(8'h1);
        #900000;  // Esperar para completar la transmisión

        // Envío de valor para A -> 0000 0101
        send_byte(8'h05);
        #200000;

        // Envío de un dato 'B'
        send_byte(8'h2);
        #200000;

        // Envío de valor para B
        send_byte(8'h03);
        #600000;

        // Envío de la operación (suma)
        send_byte(8'h3);
        #600000;

        // Envío de valor de operación (suma, 0b100000)
        send_byte(8'h20);
        #600000;

        // Envío de comando para ejecutar operación y transmitir resultado
        send_byte(8'h4);
        #2000000;
        $finish;
    end

    // Tarea para enviar un byte
    task send_byte(input [7:0] data);
        integer i;
        begin
            // Start bit
            rx = 0;
            #104160;  // 1 bit period for 9600 baud rate

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                #104160;  // 1 bit period
            end

            // Stop bit
            rx = 1;
            #104160;
        end
    endtask

endmodule
