# Ghi chép Openresty

## Cài đặt Openresty trên CentOS7
- Môi trường
  ```sh
  [root@openresty1 ~]# cat /etc/redhat-release
  CentOS Linux release 7.3.1611 (Core)
  ```


### Thiết lập hostname, ip , firewall
- Đặt hostname 
  ```sh
  hostnamectl set-hostname openresty1
  ```
  
- Cấu hình IP
  ```sh
  echo "Setup IP  eno16777728"
  nmcli c modify eno16777728 ipv4.addresses 10.10.10.161/24
  nmcli c modify eno16777728 ipv4.method manual
  nmcli con mod eno16777728 connection.autoconnect yes

  echo "Setup IP  eno33554952"
  nmcli c modify eno33554952 ipv4.addresses 172.16.69.161/24
  nmcli c modify eno33554952 ipv4.gateway 192.168.20.254
  nmcli c modify eno33554952 ipv4.dns 8.8.8.8
  nmcli c modify eno33554952 ipv4.method manual
  nmcli con mod eno33554952 connection.autoconnect yes

  sudo systemctl disable firewalld
  sudo systemctl stop firewalld
  sudo systemctl disable NetworkManager
  sudo systemctl stop NetworkManager
  sudo systemctl enable network
  sudo systemctl start network

  sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

  init 6
  ````