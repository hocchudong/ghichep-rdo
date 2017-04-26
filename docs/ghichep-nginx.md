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


- Tạo 1 trang html trên `apache1` để test 
  ```sh
  cat << EOF >  /var/www/html/index.html
  <html>
  <body>
  <div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
  `hostname`
  </div>
  </body>
  </html>
  EOF
  ```
- Truy cập vào IP của `apache1`, sẽ thấy hostname của `apache1`

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


- Tạo 1 trang html trên `apache2` để test 
  ```sh
  cat << EOF >  /var/www/html/index.html
  <html>
  <body>
  <div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
  `hostname`
  </div>
  </body>
  </html>
  EOF
  ```
- Truy cập vào IP của `apache2`, sẽ thấy hostname của `apache2`
### Cài đặt NGINX trên LoadBlancing1

- Khaibáo repos để tăng tốc độ cài đặt
  ```
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```

- Đặt hostname cho LoadBlancing1
  ```sh
  hostnamectl set-hostname lb1
  
  echo "172.16.69.23 lb1" >> /etc/hosts
  echo "172.16.69.24 lb2" >> /etc/hosts
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

- Đăng nhập lại vào máy LoadBlancing1 với địa chỉ ở trên và cài nginx
  ```sh
  yum install -y wget 
  yum install -y epel-release
  
  yum --enablerepo=epel -y install nginx
  ```

- Khởi động nginx
  ```sh
  systemctl start nginx 
  systemctl enable nginx
  ```

- Kiểm tra trạng thái của NGINX
  ```sh
  systemctl status nginx 
  ```

- Kiểm tra phiên bản của nginx bằng lệnh `nginx -v`
  ```sh
  [root@lb1 ~]# nginx -v
  nginx version: nginx/1.10.2
  ```
  
- Tạo 1 trang html trên LoadBlancing1 để test 
  ```sh
  cat << EOF > /usr/share/nginx/html/index.html
  <html>
  <body>
  <div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
  `hostname`
  </div>
  </body>
  </html>
  EOF
  ```
- Khởi động lại nginx
  ```sh
  systemctl restart nginx 
  ```
  
- Truy cập vào IP của LoadBlancing1, sẽ thấy hostname của LoadBlancing1

### Cài đặt NGINX trên LoadBlancing2 
- Khaibáo repos để tăng tốc độ cài đặt
  ```sh
  echo "proxy=http://123.30.178.220:3142" >> /etc/yum.conf 
  yum -y update
  ```
- Đặt hostname cho LoadBlancing2
  ```sh
  hostnamectl set-hostname lb2
  
  echo "172.16.69.23 lb1" >> /etc/hosts
  echo "172.16.69.24 lb2" >> /etc/hosts
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

- Đăng nhập lại vào máy LoadBlancing2 với địa chỉ ở trên và cài nginx trên LoadBlancing2
  ```sh
  yum install -y wget 
  yum install -y epel-release

  yum --enablerepo=epel -y install nginx
  ```
  
- Khởi động nginx
  ```sh
  systemctl start nginx 
  systemctl enable nginx
  ```

- Kiểm tra trạng thái của NGINX
  ```sh
  systemctl status nginx 
  ```

- Kiểm tra phiên bản của nginx bằng lệnh `nginx -v`
  ```sh
  [root@lb2 ~]# nginx -v
  nginx version: nginx/1.10.2
  ```
  
- Tạo 1 trang html trên LoadBlancing2 để test 
  ```sh
  cat << EOF > /usr/share/nginx/html/index.html
  <html>
  <body>
  <div style="width: 100%; font-size: 40px; font-weight: bold; text-align: center;">
  `hostname`
  </div>
  </body>
  </html>
  EOF
  ```
  
- Khởi động lại nginx
  ```sh
  systemctl restart nginx 
  ```
  
- Truy cập vào IP của LoadBlancing2, sẽ thấy hostname của LoadBlancing2

## Cài đặt pacemaker và corosync để tạo cluster cho nginx 
- Packer dùng để quản lý các tài nguyên (web server - nginx, database, IP VIP)
- Corosync dùng để làm `messenger` theo dõi tình trạng của các tài nguyên ở trên. 


### Cài đặt pacemaker trên LB1 và trên LoadBlancing2 
- Lưu ý:
  - Bước này thực hiện trên cả 2 máy chủ LoadBlancing (LoadBlancing1 và LoadBlancing2)

- Cài đặt `pacemaker` trên máy chủ LoadBlancing1 (làm tương tự với LoadBlancing2)
  ```sh
  yum -y install pacemaker pcs
  ```
  - Sau khi cài xong, sử dụng lệnh dưới để kiểm tra xem có gói pacemaker và corosync hay chưa `rpm -qa | egrep "pacemaker|corosync"`
    ```sh
    [root@lb1 ~]# rpm -qa | egrep "pacemaker|corosync"
    corosynclib-2.4.0-4.el7.x86_64
    pacemaker-cluster-libs-1.1.15-11.el7_3.4.x86_64
    pacemaker-1.1.15-11.el7_3.4.x86_64
    corosync-2.4.0-4.el7.x86_64
    pacemaker-cli-1.1.15-11.el7_3.4.x86_64
    pacemaker-libs-1.1.15-11.el7_3.4.x86_64
    ```
  
- Khởi động pacemaker
  ```sh
  systemctl start pcsd 
  systemctl enable pcsd
  ```

- Đặt mật khẩu cho user admin của cluster, nhập mật khẩu mà bạn muốn sử dụng.
  ```sh
  passwd hacluster
  ```
  - Lưu ý: đặt mật khẩu giống nhau trên cả 2 node LoadBlancing1 và LoadBlancing2. User cho 2 node là `hacluster`

### Tạo cluster 
- Đứng trên 1 trong 2 node để thực hiện các bước dưới. Chỉ đứng trên 1 node thực hiện bước này 
- Thực hiện lệnh dưới để thiết lập xác thực giữa `LoadBlancing1` và `LoadBlancing2`, trong hướng dẫn này tôi đứng trên LB1 
  ```sh
  pcs cluster auth lb1 lb2
  ```
  - Kết quả như sau:
    ```
    [root@lb1 ~]# pcs cluster auth lb1 lb2
    Username: hacluster
    Password:
    lb1: Authorized
    lb2: Authorized
    ```
- Cấu hình cluster 
  ```sh
  pcs cluster setup --name ha_cluster lb1 lb2
  ```

  - Kết quả như sau
    ```sh
    [root@lb1 ~]# pcs cluster setup --name ha_cluster lb1 lb2
    Destroying cluster on nodes: lb1, lb2...
    lb1: Stopping Cluster (pacemaker)...
    lb2: Stopping Cluster (pacemaker)...
    lb1: Successfully destroyed cluster
    lb2: Successfully destroyed cluster

    Sending cluster config files to the nodes...
    lb1: Succeeded
    lb2: Succeeded

    Synchronizing pcsd certificates on nodes lb1, lb2...
    lb1: Success
    lb2: Success

    Restarting pcsd on the nodes in order to reload the certificates...
    lb1: Success
    lb2: Success
    [root@lb1 ~]#
    ```
    
- Khởi động service cho cluster. Chỉ đứng trên 1 node tại 1 thời điểm thực hiện bước này 
  ```sh
  pcs cluster start --all 
  ```
  - Kết quả
  ```sh
  [root@lb1 ~]# pcs cluster start --all
  lb2: Starting Cluster...
  lb1: Starting Cluster...
  ```


- Kích hoạt cluster. Chỉ đứng trên 1 node tại 1 thời điểm thực hiện bước này 
  ```sh
  pcs cluster enable --all 
  ```
  - Kết quả: 
  ```sh
  [root@lb1 ~]# pcs cluster enable --all
  lb1: Cluster Enabled
  lb2: Cluster Enabled
  ```

- Kiểm tra trạng thái của cluster. Có thể đứng trên 1 trong node bất kỳ của cụm cluster để kiểm tra
  ```sh
  pcs status cluster 
  ```
  - Kết quả:
  ```sh
  [root@lb1 ~]#   pcs status cluster
  Cluster Status:
   Stack: corosync
   Current DC: lb2 (version 1.1.15-11.el7_3.4-e174ec8) - partition with quorum
   Last updated: Wed Apr 26 07:53:32 2017         Last change: Wed Apr 26 00:53:05 2017 by hacluster via crmd on lb2
   2 nodes and 0 resources configured

  PCSD Status:
    lb1: Online
    lb2: Online
  ```
  
- Lưu ý: tới đây mới chỉ đảm bảo cụm cluster đã sẵn sàng để hoạt động, cần add thêm các `resources agent` để pacemaker quản lý. Thực hiện ở phần dưới.

### Thực hiện add các `resources agent` để pacemaker quản lý. Trong hướng dẫn này sẽ thêm các `resources agent` của NGINX và IP VIP.
