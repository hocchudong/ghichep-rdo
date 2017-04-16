### Hương dẫn cài đặt OpenStack Mitaka bằng Packstack trên CENTOS 7.x

## Giới thiệu

- Lưu ý: Trong tài liệu này chỉ thực hiện cài đặt OpenStack, bước cài đặt CEPH ở tài liệu khác.
- Packstack là một công cụ cài đặt OpenStack nhanh chóng.
- Packstack được phát triển bởi redhat
- Chỉ hỗ trợ các distro: RHEL, Centos
- Tự động hóa các bước cài đặt và lựa chọn thành phần cài đặt.
- Nhanh chóng dựng được môi trường OpenStack để sử dụng làm PoC nội bộ, demo khách hàng, test tính năng.
- Nhược điểm 1 : Đóng kín các bước cài đối với người mới.
- Nhược điểm 2: Khó bug các lỗi khi cài vì đã được đóng gói cùng với các tool cài đặt tự động (puppet)


## Chuẩn bị

- Sử dụng VMware Workstation để tạo các máy cài đặt OpenStack
- Distro: CentOS 7.x
- OpenStack Mitaka
- NIC1 - eno16777728: là dải mạng sử dụng cho các traffic MGNT + API + DATA VM. Dải mạng này sử dụng chế độ hostonly trong VMware Workstation
- NIC2 - eno33554952 : Là dải mạng mà các máy ảo sẽ giao tiếp với bên ngoài. Dải mạng này sử dụng chế độ bridge hoặc NAT của VMware Workstation


### Mô hình

![topology](../images/Topology_OPS_CEPH_RDO.png)

- Lưu ý: Khi dựng các máy chỉ cần dựng đủ các node cho OpenStack, máy CEPH được sử dụng ở tài liệu khác.

### IP Planning

![ipplanning](../images/IP_Planning_OpenStack_CEPH_RDO.png)

- Lưu ý: 
  - Khi dựng các máy chỉ cần dựng đủ các node cho OpenStack, máy CEPH được sử dụng ở tài liệu khác.
  - Sử dụng đúng thứ tự các interface (NICs) của máy để cài đặt OpenStack.
  - Sử dụng đúng các dải địa chỉ IP.

### Các bước chuẩn bị trên trên Controller


- Thiết lập hostname

	```sh
	hostnamectl set-hostname controller
	```

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.61/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.61/24
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
- Khai báo repos cho OpenStack Mitaka

   ```sh
    sudo yum install -y centos-release-openstack-mitaka
    yum update -y

    sudo yum install -y wget crudini
    yum install -y openstack-packstack
    init 6
    ```



### Các bước chuẩn bị trên trên Compute1

- Thiết lập hostname

    ```sh
    hostnamectl set-hostname compute1
    ```

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.62/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.62/24
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

- Khai báo repos cho OpenStack Mitaka

   ```sh
    sudo yum install -y centos-release-openstack-mitaka
    yum update -y

    sudo yum install -y wget crudini
    yum install -y openstack-packstack
    init 6
    ```

### Các bước chuẩn bị trên trên Compute2

- Thiết lập hostname

    ```sh
    hostnamectl set-hostname compute2
    ```

- Thiết lập IP 

    ```sh
    echo "Setup IP  eno16777728"
    nmcli c modify eno16777728 ipv4.addresses 10.10.10.63/24
    nmcli c modify eno16777728 ipv4.method manual

    echo "Setup IP  eno33554952"
    nmcli c modify eno33554952 ipv4.addresses 172.16.69.63/24
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

- Khai báo repos cho OpenStack Mitaka

   ```sh
    sudo yum install -y centos-release-openstack-mitaka
    yum update -y

    sudo yum install -y wget crudini
    yum install -y openstack-packstack
    init 6
    ```

    
### Bắt đầu cài đặt `packstack` trên trên Controller

- Đứng trên Controler và thực hiện các bước cài đặt dưới.

- Cài đặt với mô hình Provider network và self service network. Lưu ý: khi cài xong bước này, máy ảo có thể gắn vào dải `provider` hoặc `selfservice`
- SSH vào máy chủ Controller
- Sử dụng lệnh dưới để cài OpenStack.
- Khi cài, màn hình sẽ yêu cầu nhập mật khẩu của các máy COM1 và COM2, packstack sẽ tự động cài trên các máy này mà ko cần thao tác.

- Kết thúc quá trình cài, màn hình sẽ có thông báo để sử dụng OpenStack


    ```sh
    packstack --allinone \
        --default-password=Welcome123 \
        --os-cinder-install=y \
        --os-ceilometer-install=y \
        --os-trove-install=n \
        --os-ironic-install=n \
        --nagios-install=n \
        --os-swift-install=y \
        --os-gnocchi-install=y \
        --os-aodh-install=y \
        --os-neutron-ovs-bridge-mappings=extnet:br-ex \
        --os-neutron-ovs-bridge-interfaces=br-ex:eno33554952 \
        --os-neutron-ovs-bridges-compute=br-ex \
        --os-neutron-ml2-type-drivers=vxlan,flat \
        --os-controller-host=172.16.69.61 \
        --os-compute-hosts=172.16.69.62, 172.16.69.63 \
        --os-neutron-ovs-tunnel-if=eno16777728 \
        --provision-demo=n
	```

###  Upload images, tạo network, chỉnh rule

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