import serial
import time
import signal

# Open the serial port
ser = serial.Serial('COM3', 115200, parity=serial.PARITY_NONE)

# Open a CSV file for writing
with open('data.csv', 'w', newline='') as file:
    # file.write('[')

    # def exit_program(signum, frame):
    #     file.write(']')
    #     exit(1)

    #signal.signal(signal.SIGINT, exit_program)
    while True:
        line = ser.readline().decode().strip()
        print(line)
        file.write(line + ',')
        time.sleep(1)
