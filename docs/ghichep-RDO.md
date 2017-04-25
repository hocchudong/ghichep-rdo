# Các ghi chép khi cài đặt RDO - packstack

### Mục lục

[I. Cài đặt RDO trên 01 máy](#1)

[II. Cài đặt RDO đồng thời trên nhiều node](#2)

[III. Ghi chép khác](#3)

[IV. Các lệnh trong packstack](#4)


<a name="1"></a>
## I. Cài đặt RDO trên 01 máy

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

    - Hoặc cài với 1 lệnh dưới

    ```sh
    packstack \
    --install-hosts=172.16.69.30 \
    --default-password=Welcome123 \
    --os-cinder-install=y \
    --os-ceilometer-install=y \
    --os-trove-install=n \
    --os-ironic-install=n \
    --nagios-install=n \
    --os-swift-install=n \
    --os-gnocchi-install=n \
    --os-aodh-install=n \
    --os-neutron-ovs-bridge-mappings=extnet:br-ex \
    --os-neutron-ovs-bridge-interfaces=br-ex:eno33554952 \
    --os-neutron-ml2-type-drivers=vxlan,flat \
    --os-neutron-ovs-tunnel-if=eno16777728 \
    --provision-demo=n
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
## II. Cài đặt RDO đồng thời trên nhiều node

- Giải sử có 03 node, bao gồm: `Controller` (CTL1), `Compute1` (COM1) và `Compute2` (COM2)

- Mỗi máy có 02 NICs (tên NIC có thể khác nhau, ví dụ eno16777728, eth0, em1...:
 - eno16777728: 10.10.10.0/24
 - eno33554952: 172.16.69.0/24 , gateway 172.16.69.1


### Bước 1: Thiết lập IP và cài các gói bổ trợ trên các node

#### Controller1

- Thiết lập hostname

    ```sh
    hostnamectl set-hostname controller
    ```

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
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    init 6
    ```

- Cách 1: Khai báo các gói để cài đặt OpenStack stables mới nhất (Hiện tại là newton)

    - Đối với CENTOS
        ```sh
        sudo yum install -y centos-release-openstack-newton
        yum -y update
        yum -y upgrade

        sudo yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

    - Đối với RHEL 7.x
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-4.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

- Cách 2: Khai báo các gói để cài đặt OpenStack mới nhất đang phát triển (vào thời điểm này là Ocacta)

    ```sh
    sudo yum install -y wget crudini

    cd /etc/yum.repos.d/
    wget http://trunk.rdoproject.org/centos7/delorean-deps.repo
    wget https://trunk.rdoproject.org/centos7-master/current/delorean.repo

    cd /root/
    yum install -y openstack-packstack 

    init 6
    ```

- Cách 3: Khai báo các gói để cài đặt OpenStack chỉ định, giả sử bản OpenStack Mitaka

    - Trên CENTOS 7.x:
        ```sh
        yum install -y centos-release-openstack-mitaka
        yum -y update
        yum -y upgrade

        yum install -y wget crudini
        yum install -y openstack-packstack

        init 6
        ```

    - Trên RHEL 7.x: 
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```


#### Trên Compute1

- Thiết lập hostname

    ```sh
    hostnamectl set-hostname compute1
    ```

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
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    ```

- Cách 1: Khai báo các gói để cài đặt OpenStack stables mới nhất (Hiện tại là newton)

    - Đối với CENTOS
        ```sh
        sudo yum install -y centos-release-openstack-newton
        yum -y update
        yum -y upgrade

        sudo yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

    - Đối với RHEL 7.x
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-4.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

- Cách 2: Khai báo các gói để cài đặt OpenStack mới nhất đang phát triển (vào thời điểm này là Ocacta)

    ```sh
    sudo yum install -y wget crudini

    cd /etc/yum.repos.d/
    wget http://trunk.rdoproject.org/centos7/delorean-deps.repo
    wget https://trunk.rdoproject.org/centos7-master/current/delorean.repo

    cd /root/
    yum install -y openstack-packstack 

    ```

- Cách 3: Khai báo các gói để cài đặt OpenStack chỉ định, giả sử bản OpenStack Mitaka

    - Trên CENTOS 7.x:
        ```sh
        yum install -y centos-release-openstack-mitaka
        yum -y update
        yum -y upgrade

        yum install -y wget crudini
        yum install -y openstack-packstack

        init 6
        ```

    - Trên RHEL 7.x: 
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

#### Trên Compute2

- Thiết lập hostname

    ```sh
    hostnamectl set-hostname compute2
    ```

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
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

    ```

- Cách 1: Khai báo các gói để cài đặt OpenStack stables mới nhất (Hiện tại là newton)

    - Đối với CENTOS
        ```sh
        sudo yum install -y centos-release-openstack-newton
        yum -y update
        yum -y upgrade

        sudo yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

    - Đối với RHEL 7.x
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-newton/rdo-release-newton-4.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```

- Cách 2: Khai báo các gói để cài đặt OpenStack mới nhất đang phát triển (vào thời điểm này là Ocacta)

    ```sh
    sudo yum install -y wget crudini

    cd /etc/yum.repos.d/
    wget http://trunk.rdoproject.org/centos7/delorean-deps.repo
    wget https://trunk.rdoproject.org/centos7-master/current/delorean.repo

    cd /root/
    yum install -y openstack-packstack 

    init 6
    ```

- Cách 3: Khai báo các gói để cài đặt OpenStack chỉ định, giả sử bản OpenStack Mitaka

    - Trên CENTOS 7.x:
        ```sh
        yum install -y centos-release-openstack-mitaka
        yum -y update
        yum -y upgrade

        yum install -y wget crudini
        yum install -y openstack-packstack

        init 6
        ```

    - Trên RHEL 7.x: 
        ```sh
        yum install https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm
        yum -y update
        yum -y upgrade

         yum install -y wget crudini
        yum install -y openstack-packstack
        init 6
        ```


### Thực hiện cài RDO
- SSH vào máy chủ Controller
- Sử dụng lệnh dưới để cài OpenStack.
- Khi cài, màn hình sẽ yêu cầu nhập mật khẩu của các máy COM1 và COM2, packstack sẽ tự động cài trên các máy này mà ko cần thao tác.

- Có 02 lựa chọn sau: 
 - Lựa chọn 1: Cài đặt với mô hình Self service network

    ```sh
    packstack --allinone \
        --default-password=Welcome123 \
        --os-cinder-install=y \
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
        --os-controller-host=172.16.69.30 \
        --os-compute-hosts=172.16.69.31,172.16.69.32 \
        --os-neutron-ovs-tunnel-if=eno16777728 \
        --provision-demo=n
     ```
 - Lựa chọn 2: Cài đặt với mô hình Provider network và self service network

    ```sh
    packstack --allinone \
        --default-password=Welcome123 \
        --os-cinder-install=y \
        --os-ceilometer-install=n \
        --os-trove-install=n \
        --os-ironic-install=n \
        --nagios-install=n \
        --os-swift-install=n \
        --os-gnocchi-install=n \
        --os-aodh-install=n \
        --os-neutron-ovs-bridge-mappings=extnet:br-ex \
        --os-neutron-ovs-bridge-interfaces=br-ex:eno33554952 \
        --os-neutron-ovs-bridges-compute=br-ex \
        --os-neutron-ml2-type-drivers=vxlan,flat \
        --os-controller-host=172.16.69.30 \
        --os-compute-hosts=172.16.69.31,172.16.69.32 \
        --os-neutron-ovs-tunnel-if=eno16777728 \
        --provision-demo=n
     ```

 - Trong lệnh packstack trên đã dùng tùy chọn để tạo ra mô hình sử dụng cả provider và selfservice đó là  `--os-neutron-ovs-bridges-compute=br-ex`

- Kết thúc quá trình cài, màn hình sẽ có thông báo để sử dụng OpenStack

### Upload image, tạo network, router , máy ảo

- Thực thi biến môi trường

    ```sh
    source ~/keystonerc_admin
    ```

- Upload images

```sh
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
image-create --name='cirros' \
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
    --enable_dhcp=True --dns-nameserver 8.8.4.4 \
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
## III. Ghi chép khác

- Fix lỗi không nhận metadata khi dùng provider network trong openstack newton sử dụng packstack để cài đặt
  - Chỉnh dòng dưới để xử lý lỗi không nhận hostname khi tạo máy ảo, trong file `/etc/neutron/dhcp_agent.ini` trên `Controller node` và khởi động lại các service của neutron trên Controller node. 
    ```sh
    enable_isolated_metadata = True
    ```
  - Minh họa: http://prntscr.com/f0gqo9

- Fix lỗi không sử dụng được console khi cài đặt OpenStack bằng Packstack trên nhiều node
  - Thay hostname trong dòng dưới ở file `/etc/nova/nova.conf` bằng IP của chính máy compute đó.
    ```sh
    vncserver_proxyclient_address=192.168.20.22
    ```
  
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

- Cách fix cấu hình packstack có SSL với horizon
  ```sh
  https://thaiopen.github.io/sipacloudcourse/packstack.html#install-openstack-puppet-module
  ```

#### Cấu hình Network cho RHEL

  
### Các ghi chép với CentOS & RHEL

- Đăng ký tài khoản dùng thử trong RHEL

    ```sh
    subscription-manager register --username maianhbao1@vietstack.vn --password c0ng@3010 --auto-attach
    ```
    

- Mô hình provider network và selfserver network trên cùng 1 máy có 02 NICs

     ```sh
     packstack \
        --install-hosts=172.16.69.30 \
        --default-password=Welcome123 \
        --os-cinder-install=y \
        --os-ceilometer-install=y \
        --os-trove-install=n \
        --os-ironic-install=n \
        --nagios-install=n \
        --os-swift-install=n \
        --os-gnocchi-install=n \
        --os-aodh-install=n \
        --os-neutron-ovs-bridge-mappings=extnet:br-ex \
        --os-neutron-ovs-bridge-interfaces=br-ex:eno33554952 \
        --os-neutron-ml2-type-drivers=vxlan,flat \
        --os-neutron-ovs-tunnel-if=eno16777728 \
        --provision-demo=n
        ```

<a name="4"></a>
## IV. Các lệnh trong `packstack`

- Generate answer file

    ```sh
    packstack --gen-answer-file
    ```
    
- Reuse an answer file

    ```sh
    packstack --answer-file=/path/to/packstack_answers.txt
    ```
