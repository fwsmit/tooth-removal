# Emulate sensor using a socket
import socket
import time
import struct
from math import sin

def main():
    # Create a socket and bind to the IP, port
    server = socket.create_server(("127.0.0.1",
                                    2001),
                                    family = socket.AF_INET)
    # Move to listen state
    server.listen()

    # Serve to connection requests
    print("Server starts to accept connections from clients...")
    while(True):
        serveOn = server.accept()
        print("Connection accepted...client details:",serveOn[1])
        ack = bytes([0x0, 0x0])
        recv_msg(serveOn)
        serveOn[0].send(ack)
        recv_msg(serveOn)
        serveOn[0].send(ack)
        #print("Sending greetings to client")
        try:
            while (True):
                Fx = 1.25 # sin(time.time())
                Fy = 1.5 # sin(time.time())
                Fz = 1.5 # sin(time.time())
                Tx = 1.5 # sin(time.time())
                Ty = 1.5 # sin(time.time())
                Tz = 1.5 # sin(time.time())
                data = struct.pack('!6d', Fx, Fy, Fz, Tx, Ty, Tz)
                msg = bytes([50]+[0])+data
                #print(msg)
                #print(len(msg))
                serveOn[0].send(msg)
                #print("Sending message to client")
                time.sleep(0.01)
        except (BrokenPipeError, ConnectionResetError):
            print("Client disconnected")
        serveOn[0].close()
        print("Connection to client closed")


def recv_msg(serveOn):
    clientMsg=serveOn[0].recv(1024)
    print("Message received:%s"%clientMsg)


if __name__ == "__main__":
	main()
