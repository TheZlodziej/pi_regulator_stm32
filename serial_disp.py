import serial
import time

# Open the serial port
ser = serial.Serial('COM3', 115200, parity=serial.PARITY_NONE)

while True:
    line = ser.readline().decode().strip()
    print(line)
    time.sleep(1)
