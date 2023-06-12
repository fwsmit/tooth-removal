# Sensor connection

The sensor we use is the Nordbo NRS-6200-D80. It connects over ethernet to your
PC. After connecting the ethernet cable, you will need to change a couple of
network settings for this network.

- ipv4 method: manual
- ipv4 address: 192.168.0.199
- ipv4 gateway: 192.168.0.1
- ipv4 dns: 192.168.0.1
- ipv4 subnet mask: 255.255.255.0 or /24


You can also use the following command on Linux:

```
nmcli connection modify 'local' connection.autoconnect yes ipv4.method manual ipv4.address 192.168.0.199/24 ipv4.gateway 192.168.0.1 ipv4.dns 192.168.0.1
```
