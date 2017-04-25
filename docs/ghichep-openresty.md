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
  ````
  
### Khai báo repos cho Openresty
- Đăng nhập lại OS với IP ở trên với quyền `root`
- Cài đặt tiện ích 
  ```sh
  yum install -y yum-utils
  ```
- Khai báo repos
  ```sh
  sudo yum install -y epel-release
  sudo yum-config-manager --add-repo https://openresty.org/yum/centos/OpenResty.repo
  ```
  - Sau khi kết thúc lệnh trên, trong thư mục `/etc/yum.repos.d` sẽ xuất hiện file `OpenResty.repo` chứa repos của `OpenResty`

- Kiểm chứng lại bằng lệnh liệt kê tất cả các gói trong repos của `OpenResty`
  ```sh
  sudo yum --disablerepo="*" --enablerepo="openresty" list available
  ```
  
- Cài đặt openresty
  ```sh
  sudo yum install openresty
  ```