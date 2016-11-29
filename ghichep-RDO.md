# Các ghi chép khi cài đặt RDO - packstack

### Mục lục

[1. Cài đặt RDO trên 01 máy](#1)

[2. Cài đặt RDO đồng thời trên nhiều node](#2)

[3. Ghi chép khác](#3)

[4. Các lệnh trong packstack](#4)


<a name="1"></a>
## 1. Cài đặt RDO trên 01 máy

### Bước 1: Chuẩn bị

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
    
- Setup IP tĩnh cho máy cài đặt RDO

    ```sh
    echo "Setup IP  eth0"
    nmcli c modify eth0 ipv4.addresses 10.10.10.30/24
    nmcli c modify eth0 ipv4.method manual

    echo "Setup IP  eth1"
    nmcli c modify eth1 ipv4.addresses 172.16.69.30/24
    nmcli c modify eth1 ipv4.gateway 172.16.69.1
    nmcli c modify eth1 ipv4.dns 8.8.8.8
    nmcli c modify eth1 ipv4.method manual
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
    
- Vô hiệu hóa `SELINUX`

    ```sh
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    ```
    
- Khởi động lại máy

    ```sh
    init 6
    ```
    
### Bước 2: Khai báo repos

- Đăng nhập vào máy chủ với quyền `root` và thực hiện các bước dưới
- Khai báo repos cho OpenStack Mitaka và update

    ```sh
    sudo yum install -y centos-release-openstack-mitaka
    sudo yum update -y
    ```
### Bước 3: Cài đặt công cụ `packstack` và gói bổ trợ

- Cài đặt công cụ packstack đóng gói cho RHEL, CentOS

    ```sh
    sudo yum install -y wget 
    sudo yum install -y openstack-packstack    
    ```

- Khởi động lại máy

    ```sh
    init 6
    ```
    
## Thực thi `packstack` để cài đặt OpenStack

- Login với quyền root và lựa chọn một trong số cách thực thi sau

### Bước 4: Tùy chọn mặc định khi thực thi `packstack`

### Bước 4.1: Cài đặt với các giá trị mặc định (Chọn 4.1 thì bỏ qua 4.2)

- Tùy chọn 1: với các giá trị mặc định: 

    ```sh
    packstack --allinone
    ```  
    
### Bước 4.2: Cài đặt với network tùy chọn theo hệ thống của bạn (Chọn 4.2 thì bỏ qua 4.1)  
  
- Tùy chọn 2: 
    
    - Với dải mạng đã có sẵn (eth1 là card mạng để máy ảo giao tiếp với bên ngoài.)

        ```sh
        packstack --allinone --provision-demo=n --os-neutron-ovs-bridge-mappings=extnet:br-ex --os-neutron-ovs-bridge-interfaces=br-ex:eth1 --os-neutron-ml2-type-drivers=vxlan,flat
        ```
     
    - Lúc này file ` /etc/sysconfig/network-scripts/ifcfg-br-ex` sẽ có nội dung như sau:
    
        ```sh
        ...
        ```
    
    - Setup interface cho card bridge `/etc/sysconfig/network-scripts/ifcfg-eth0`
    
        ```sh
        DEVICE=eth1
        TYPE=OVSPort
        DEVICETYPE=ovs
        OVS_BRIDGE=br-ex
        ONBOOT=yes
        ```
        
- Tạo network 

    ```sh
    neutron net-create external_network --provider:network_type flat --provider:physical_network extnet  --router:external

    neutron subnet-create --name public_subnet --enable_dhcp=False --allocation-pool=start=192.168.122.10,end=192.168.122.20 \
                        --gateway=192.168.122.1 external_network 192.168.122.0/24
    ```

- Tạo router

    ```sh
    neutron router-create router1
    neutron router-gateway-set router1 external_network
    ```

- Tạo private network

    ```sh
    neutron net-create private_network
    neutron subnet-create --name private_subnet private_network 192.168.100.0/24
    ```

- Gán interface cho router 

    ```sh
    neutron router-interface-add router1 private_subnet
    ```


    - Tham khảo
    
        ```sh
        https://www.rdoproject.org/networking/neutron-with-existing-external-network/
        ```
    
### Cài thêm node compute tiếp theo

- Thực hiện giống các bước chuẩn bị như node CTL
- Đứng từ máy đầu tiên (CTL), copy file answer sang máy thứ 2 (COM1)
- Sửa dòng `CONFIG_COMPUTE_HOSTS` trong file answer thành IP của máy thứ 2 COM1

<a name="2"></a>
## 2. Cài đặt RDO đồng thời trên nhiều node

- Giải sử có 03 node, bao gồm: `Controller` (CTL1), `Compute1` (COM1) và `Compute2` (COM2)

- Mỗi máy có 02 NICs (tên NIC có thể khác nhau, ví dụ eno16777728, eth0, em1...:
 - eno16777728: 10.10.10.0/24
 - eno33554952: 172.16.69.0/24 , gateway 172.16.69.1


### Bước 1: Thiết lập IP và cài các gói bổ trợ trên các node

#### Controller1

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.30/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.30/24
    nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
    nmcli c modify eno33554952 ipv4.dns 8.8.8.8
    nmcli c modify eno33554952 ipv4.method manual


    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl disable NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    init 6
    ```

- Khai báo các gói để cài đặt OpenStack

    ```sh
    sudo yum install -y https://rdoproject.org/repos/rdo-release.rpm

    yum update -y

    sudo yum install -y wget 
    yum install -y openstack-packstack

    init 6
    ```

#### Trên Compute1

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.31/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.31/24
    nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
    nmcli c modify eno33554952 ipv4.dns 8.8.8.8
    nmcli c modify eno33554952 ipv4.method manual


    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl disable NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    init 6
    ```

- Khai báo các gói để cài đặt OpenStack

    ```sh
    sudo yum install -y https://rdoproject.org/repos/rdo-release.rpm

    yum update -y

    sudo yum install -y wget 
    yum install -y openstack-packstack

    init 6
    ```

#### Trên Compute2

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.32/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.32/24
    nmcli c modify eno33554952 ipv4.gateway 172.16.69.1
    nmcli c modify eno33554952 ipv4.dns 8.8.8.8
    nmcli c modify eno33554952 ipv4.method manual


    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl disable NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    init 6
    ```

- Khai báo các gói để cài đặt OpenStack

    ```sh
    sudo yum install -y https://rdoproject.org/repos/rdo-release.rpm

    yum update -y

    sudo yum install -y wget 
    yum install -y openstack-packstack

    init 6
    ```

### Thực hiện cài RDO
- SSH vào máy chủ Controller
- Sử dụng lệnh dưới để cài OpenStack.
- Khi cài, màn hình sẽ yêu cầu nhập mật khẩu của các máy COM1 và COM2, packstack sẽ tự động cài trên các máy này mà ko cần thao tác.

    ```sh
    packstack --allinone \
        --os-cinder-install=n \
        --os-ceilometer-install=n \
        --os-trove-install=n \
        --os-ironic-install=n \
        --nagios-install=n \
        --os-swift-install=n \
        --os-gnocchi-install=n \
        --os-aodh-install=n \
        --os-neutron-ovs-bridge-mappings=extnet:br-ex \
        --os-neutron-ovs-bridge-interfaces=br-ex:eno33554952 \
        --os-neutron-ml2-type-drivers=vxlan,flat \
        --os-compute-hosts=172.16.69.31,172.16.69.32 \
        --os-neutron-ovs-tunnel-if=eno16777728 \
        --provision-demo=n

     ```

- Kết thúc quá trình cài, màn hình sẽ có thông báo để sử dụng OpenStack

### Upload image, tạo network, router , máy ảo

- Thực thi biến môi trường

    ```sh
    source ~/keystonerc_admin
    ```

- Upload images

```sh
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
image-create --name='cirros image' \
--visibility=public \
--container-format=bare \
--disk-format=qcow2
```

- Tạo network public 

    ```sh
    neutron net-create external_network --provider:network_type flat \
    --provider:physical_network extnet  \
    --router:external \
    --shared
    ```

- Tạo subnet trong network public 

    ```sh
    neutron subnet-create --name public_subnet \
    --enable_dhcp=False \
    --allocation-pool=start=172.16.69.80,end=172.16.69.100 \
    --gateway=172.16.69.1 external_network 172.16.69.0/24
    ```

- Tạo network private

    ```sh
    neutron net-create private_network
    neutron subnet-create --name private_subnet private_network 10.0.0.0/24 \
    --dns-nameserver 8.8.8.8
    ```

- Tạo router và addd các interface

    ```sh
    neutron router-create router
    neutron router-gateway-set router external_network
    neutron router-interface-add router private_subnet
    ```

- Truy cập vào web để tạo máy ảo.

<a name="3"></a>
## 3. Ghi chép khác
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


  
### Các ghi chép với CentOS & RHEL

- Đăng ký tài khoản dùng thử trong RHEL

    ```sh
    subscription-manager register --username maianhbao1@vietstack.vn --password c0ng@3010 --auto-attach
    ```
    


<a name="4"></a
## 4. Các lệnh trong `packstack`

- Generate answer file

    ```sh
    packstack --gen-answer-file
    ```
    
- Reuse an answer file

    ```sh
    packstack --answer-file=/path/to/packstack_answers.txt
    ```
