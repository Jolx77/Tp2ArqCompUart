module tb_top;

    // Parámetros
    parameter N = 8;
    parameter CLK_FREQ = 50000000;
    parameter BAUD_RATE = 9600;
    parameter COUNT_TICKS = 16;
    reg clk;
    reg rst;
    reg rx;
    wire tx;
    wire [N-1:0]data_out;
    wire [4:0]state_output;

    // Instancia del módulo top
    top #(
        .N(N),
        .COUNT_TICKS(COUNT_TICKS)
    ) uut (
        .clk(clk),
        .reset(rst),
        .rx(rx),
        .tx(tx),
        .data_out(data_out),
        .state_output(state_output)
    );

    baudrate_generator baudrate_gen(
        .clk(clk),
        .reset(rst),
        .tick(tick)
    ) ;

    // Reloj de 50 MHz
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Periodo de 20 ns, frecuencia de 50 MHz
    end

    // Generación de rst y estímulos
    initial begin
        rst = 1;
        rx = 1;  // Inicialmente en estado alto
        #100;
        rst = 0;
        #10;
        // Envío de un dato 'A'
        send_byte(8'h1);
        #900000;  // Esperar para completar la transmisión

        // Envío de valor para A -> 0000 0111
        send_byte(8'h07);
        #200000;

        // Envío de un dato 'B'
        send_byte(8'h2);
        #200000;

        // Envío de valor para B -> 0000 0010
        send_byte(8'h2);
        #600000;

        // Envío de la operación (suma) 
        send_byte(8'h3);
        #600000;

        // Envío de valor de operación (suma, 0b100000)
        send_byte(8'h20); // 0010 0000
        #600000;

        // Envío de comando para ejecutar operación y transmitir resultado
        send_byte(8'h4);
        #2000000;
        $finish;
    end

    // Tarea para enviar un byte
    task send_byte(input [7:0] data);
        integer i;
        integer j;
        begin
            @(posedge clk);
            // Start bit
            rx = 0;
            for(j = 0;j < 16;j = j+1) begin
                @(posedge tick);
            end

            // Data bits
            for (i = 0; i < 8; i = i + 1) begin
                rx = data[i];
                for(j = 0;j < 16;j = j+1) begin
                    @(posedge tick);
                end
            end

            // Stop bit
            rx = 1;
            for(j = 0;j < 16;j = j+1) begin
                @(posedge tick);
            end
        end
    endtask

endmodule
