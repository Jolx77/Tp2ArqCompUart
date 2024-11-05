import serial
import time

def main():
    # Configuración del puerto serial
    port = '/dev/ttyUSB1'  # Reemplaza esto con el puerto correcto en tu sistema
    baud_rate = 19200

    try:
        # Abre la conexión serial
        ser = serial.Serial(port, baud_rate, timeout=1)
        print(f"Conectado a {port} a {baud_rate} bps")
        time.sleep(2)  # Tiempo para estabilizar la conexión

        print("Ingresa un número entre 0 y 255 y presiona 'Enter' para enviarlo. Presiona 'Ctrl+C' para salir.")

        while True:
            try:
                for i in range(0, 7):
                    # Leer la entrada del usuario
                    user_input = input("Número (0-255): ")

                    # Intentar convertir la entrada a un número entero
                    number = int(user_input)

                    # Validar que esté en el rango de 0 a 255
                    if 0 <= number <= 255:
                        # Convertir el número a un byte y enviarlo
                        i = i + 1
                        ser.write(bytes([number]))
                        print(f"Enviando: {number}")
                    else:
                        print("Error: El número debe estar entre 0 y 255.")

                # Leer respuesta desde la FPGA si hay
                print("Leyendo")
                time.sleep(0.1)  # Breve pausa para esperar la respuesta
                if ser.in_waiting > 0:
                    received_data = ser.read(ser.in_waiting)
                    # Convertir cada byte recibido a formato binario
                    received_bits = ' '.join(f'{byte:08b}' for byte in received_data)
                    print(f"Recibido desde FPGA (en bits): {received_bits}")

            except ValueError:
                print("Error: Por favor, ingresa un número válido.")

            # Pausa breve para evitar ocupar toda la CPU
            time.sleep(0.01)

    except serial.SerialException as e:
        print(f"Error al abrir el puerto serial: {e}")
    except KeyboardInterrupt:
        print("Interrumpido por el usuario")
    finally:
        # Cierra la conexión serial al terminar
        if ser.is_open:
            ser.close()
            print("Conexión serial cerrada")

if __name__ == "__main__":
    main()
