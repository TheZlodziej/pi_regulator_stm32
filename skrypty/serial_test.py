import serial
import time

# Open the serial port
ser = serial.Serial('COM3', 115200, parity=serial.PARITY_NONE)

uref = 20
ti = 0.05
kp = 1
kc = 1

while True:
    uref += 0.2

    line_read = ser.readline().decode().strip()
    print(line_read)

    line_sent = f'{{"Uref":{uref}}}\r\n'
    ser.write(bytes(line_sent, 'ascii'))
    print(line_sent)

    time.sleep(1)
