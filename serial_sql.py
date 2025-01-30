import serial
import sqlite3
import datetime
import serial.tools.list_ports

ports = serial.tools.list_ports.comports()
print("available ports")
print("please select one")
ports_list = []
index = 0

for port, desc, hwid in ports:
    if desc == "n/a":
        continue
    index += 1
    print(f" {index} -   Port: {port}")
    ports_list.append(port)

# Prompt the user to select a port
port = input("Enter the port number: ")
com = ports_list[int(port) - 1]

# Set up serial connection
ser = serial.Serial(com, 115200)
print("Connected to Arduino on", ser.name)

# Set up SQLite database
conn = sqlite3.connect('sensor_data.db')
cursor = conn.cursor()

# Create a table if it doesn't exist
cursor.execute('''
    CREATE TABLE IF NOT EXISTS sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        time TEXT,
        temp_sensor NUMERIC,
        tds_sensor NUMERIC,
        ph_sensor NUMERIC,
        turbidity_sensor NUMERIC
    )
''')
conn.commit()

# Read data from Arduino and store in the database
try:
    while True:
        if ser.in_waiting > 0:
            # Read a line from the serial port
            line = ser.readline().decode('utf-8').strip()

            if line.startswith("Data,"):
                # Split the data into time and value
                array = line.split(',')
                if len(array) == 6:
                    print(array[1], array[2], array[3], array[4])
                    temp_sensor = array[1]
                    tds_sensor = array[2]
                    ph_sensor = array[3]
                    turbidity_sensor = array[4]

                    # Insert data into the SQLite database
                    cursor.execute(
                        "INSERT INTO sensor_data (time, temp_sensor, tds_sensor, ph_sensor, turbidity_sensor) VALUES (?, ?, ?, ?, ?)",
                        (datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S'), temp_sensor, tds_sensor, ph_sensor, turbidity_sensor))
                    conn.commit()

except KeyboardInterrupt:
    print("Exiting...")
    ser.close()
    conn.close()
