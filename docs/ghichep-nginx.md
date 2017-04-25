# Cài đặt httpd, pacemaker, corosync
## Mô hình

## IP Planning 

### Cài đặt httpd trên máy apache1

- Khai bao repos
  ```sh 
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```

- Đặt hostname cho apache1 
  ```sh
  hostnamectl set-hostname apache1
  ```

- Đặt IP cho các NICs 
  ```sh
  echo "Setup IP  eno16777728"
  nmcli c modify eno16777728 ipv4.addresses 10.10.10.21/24
  nmcli c modify eno16777728 ipv4.method manual
  nmcli con mod eno16777728 connection.autoconnect yes

  echo "Setup IP  eno33554952"
  nmcli c modify eno33554952 ipv4.addresses 172.16.69.21/24
  nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
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
  ```

- Đăng nhập lại máy apache1 và cài đặt httpd


### Cài đặt httpd trên máy apache2

- Khaibáo repos để tăng tốc độ cài đặt
  ```sh
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```

- Đặt hostname cho máy apache2
  ```sh
  hostnamectl set-hostname apache2
  ```
  
- Đặt IP cho các NICs
  ```sh
  echo "Setup IP  eno16777728"
  nmcli c modify eno16777728 ipv4.addresses 10.10.10.22/24
  nmcli c modify eno16777728 ipv4.method manual
  nmcli con mod eno16777728 connection.autoconnect yes

  echo "Setup IP  eno33554952"
  nmcli c modify eno33554952 ipv4.addresses 172.16.69.22/24
  nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
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
  ```

- Đăng nhập lại máy apache1 và cài đặt httpd


### Cài đặt NGINX trên LB1

- Khaibáo repos để tăng tốc độ cài đặt
  ```
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```

- Đặt hostname cho LB1
  ```sh
  hostnamectl set-hostname LB1
  ```

- Đặt địa chỉ IP cho các NICs
  ```sh
  echo "Setup IP  eno16777728"
  nmcli c modify eno16777728 ipv4.addresses 10.10.10.23/24
  nmcli c modify eno16777728 ipv4.method manual
  nmcli con mod eno16777728 connection.autoconnect yes

  echo "Setup IP  eno33554952"
  nmcli c modify eno33554952 ipv4.addresses 172.16.69.23/24
  nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
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
  ```

- Đăng nhập lại vào máy LB1 với địa chỉ ở trên và cài nginx
  ```sh
  yum install -y wget 
  yum install -y epel-release
  
  yum --enablerepo=epel -y install nginx
  ```

- Khởi động nginx
  ```sh
  systemctl start nginx 
  systemctl enable nginx 

  systemctl restart nginx 
  ```

### Cài đặt NGINX trên LB2 
- Khaibáo repos để tăng tốc độ cài đặt
  ```sh
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```
- Đặt hostname cho LB2
  ```sh
  hostnamectl set-hostname LB2
  ```
- Đặt IP cho các NICs
  ```sh
  echo "Setup IP  eno16777728"
  nmcli c modify eno16777728 ipv4.addresses 10.10.10.24/24
  nmcli c modify eno16777728 ipv4.method manual
  nmcli con mod eno16777728 connection.autoconnect yes

  echo "Setup IP  eno33554952"
  nmcli c modify eno33554952 ipv4.addresses 172.16.69.24/24
  nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
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
  ```

- Đăng nhập lại vào máy LB2 với địa chỉ ở trên và cài nginx trên LB2
  ```sh
  yum install -y wget 
  yum install -y epel-release

  yum --enablerepo=epel -y install nginx
  ```
  
- Khởi động nginx
  ```sh
  systemctl start nginx 
  systemctl enable nginx 

  systemctl restart nginx 
  ```

### Cài đặt pacemaker trên LB1



