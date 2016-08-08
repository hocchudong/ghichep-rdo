# Các ghi chép khi cài đặt RDO - packstack

## Bước chuẩn bị

- Môi trường cài đặt

    ```sh

    [root@ctl1-centos7 ~]# cat /etc/redhat-release
    CentOS Linux release 7.2.1511 (Core)

    uname -a
    Linux ctl1-centos7 3.10.0-327.28.2.el7.x86_64 #1 SMP Wed Aug 3 11:11:39 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
    ```


- Setup ip tĩnh cho máy ảo

    ```sh
    - Xem lệnh setup IP ở phía dưới.
    - eth0: Managment: 10.10.10.0/24 , no gateway
    - eth1: External:  172.16.69.0/24 , gateway 172.16.69.1
    ```

- Cấu hình các gói cơ bản

    ```sh
    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network
    ```

- Khai báo repos cho OpenStack Mitaka và update

    ```sh
    sudo yum install -y centos-release-openstack-mitaka
    sudo yum update -y
    ```

- Cài đặt công cụ `packstack`

    ```sh
    sudo yum install -y openstack-packstack
    ```

- 

    
    
    
    

## Ghi chép khác
- Setup IP cho Centos 7

    ```sh
    echo "Setup IP  eth0"
    nmcli c modify eth0 ipv4.addresses 10.10.10.146/24
    nmcli c modify eth0 ipv4.method manual

    echo "Setup IP  eth1"
    nmcli c modify eth1 ipv4.addresses 172.16.69.146/24
    nmcli c modify eth1 ipv4.gateway 172.16.69.1
    nmcli c modify eth1 ipv4.dns 8.8.8.8
    nmcli c modify eth1 ipv4.method manual
    ```

- 

