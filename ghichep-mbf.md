## Chuẩn bị mô hình

### IP planning 
- Đảm bảo đúng thứ tự các NICs

![ipplanning](http://image.prntscr.com/image/ff290369f07b4197bd7d48c9188f71a0.png)

### Các bước thiết lập IP, tải gói cần tiết

#### Thực hiện trên controller

- Thiết lập IP, đảm bảo đúng thứ tự NICs

```sh
echo "Setup IP  eno50"
nmcli c modify eno50 ipv4.addresses 10.16.39.150/24
nmcli c modify eno50 ipv4.method manual

echo "Setup IP  eno56"
nmcli c modify eno56 ipv4.addresses 10.16.149.13/24
nmcli c modify eno56 ipv4.gateway 10.16.149.1
nmcli c modify eno56 ipv4.dns 8.8.8.8
nmcli c modify eno56 ipv4.method manual
```

- Cấu hình các dịch vụ cơ bản

```sh
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network
```

```sh
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/notify_only=1/notify_only=0/g' /etc/yum/pluginconf.d/search-disabled-repos.conf
```

- Khởi động lại máy

```sh
init 6
```

- Đăng nhập vào controller và cài đặt repos cho Mitaka. 

```sh
sudo yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm

yum update -y

sudo yum install -y wget crudini
yum install -y openstack-packstack
```

- Khởi động lại

```sh
init 6
```

- Chuyển sang thực hiện trên máy compute

#### Thực hiện trên compute

- Thiết lập IP, đảm bảo đúng thứ tự NICs

```sh
echo "Setup IP  eno50"
nmcli c modify eno50 ipv4.addresses 10.16.39.151/24
nmcli c modify eno50 ipv4.method manual

echo "Setup IP  eno56"
nmcli c modify eno56 ipv4.addresses 10.16.149.12/24
nmcli c modify eno56 ipv4.gateway 10.16.149.1
nmcli c modify eno56 ipv4.dns 8.8.8.8
nmcli c modify eno56 ipv4.method manual
```

- Cấu hình các dịch vụ cơ bản

```sh
sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/notify_only=1/notify_only=0/g' /etc/yum/pluginconf.d/search-disabled-repos.conf
```

- Khởi động lại máy

```sh
init 6
```

- Đăng nhập lại máy compute và cài repos

```sh
sudo yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm

yum update -y

sudo yum install -y wget crudini
yum install -y openstack-packstack
```

- Khởi động lại

```sh
init 6
```

- Chuyển sang máy chủ controller để thực hiện bước tiếp theo

#### Cài đặt OpenStack

- Thực hiện lệnh dưới để cài trên controller, lệnh này sẽ tự động cài trên compute
- Lưu ý nhập đúng IP của các máy controller và compute
- Nếu có nhiều hơn 1 máy compute thì sử dụng dấu phẩy và các ip tiếp theo, ví dụ `--os-compute-hosts=10.16.149.12,10.16.149.14 ` 
- Lưu ý:
 - `eno56` : Được dùng để mapping openvswitch và card mạng vật lý của các máy chủ controller và compute
 - `eno50`: Được dùng để truyền thông giữu các máy ảo với nhau.

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
    --os-neutron-ovs-bridge-interfaces=br-ex:eno56 \
    --os-neutron-ovs-bridges-compute=br-ex \
    --os-neutron-ml2-type-drivers=vxlan,flat \
    --os-controller-host=10.16.149.13 \
    --os-compute-hosts=10.16.149.12 \
    --os-neutron-ovs-tunnel-if=eno50 \
    --provision-demo=n
```

Bước tạo network, máy ảo.


### Hướng dẫn cài packstack ở HN

#### IP range các máy

##### Controller

- eno49: 
 - IP: 10.3.11.20
 - Subnetmask: /24
 - Gateway: 10.3.11.99

- eno53: 
 - IP: 10.3.10.37
 - Subnetmask: /24
 - Gateway: 10.3.10.99

##### Compute 

- eno49: 
 - IP: 10.3.11.21
 - Subnetmask: /24
 - Gateway: 10.3.11.99

- eno53: 
 - IP: 10.3.10.38
 - Subnetmask: /24
 - Gateway: 10.3.10.99

 #### Chuẩn bị trên controller

 - Cài đặt IP và thiết lập mạng

 ```sh
 echo "Setup IP  eno49"
nmcli c modify eno49 ipv4.addresses 10.3.11.20/24
nmcli c modify eno49 ipv4.method manual

echo "Setup IP  eno53"
nmcli c modify eno53 ipv4.addresses 10.3.10.37/24
nmcli c modify eno53 ipv4.gateway 10.3.10.99
nmcli c modify eno53 ipv4.dns 8.8.8.8
nmcli c modify eno53 ipv4.method manual

sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/notify_only=1/notify_only=0/g' /etc/yum/pluginconf.d/search-disabled-repos.conf
````



- Đăng nhập vào controller và cài đặt repos cho Mitaka.

```sh
sudo yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm

yum update -y

sudo yum install -y wget crudini
yum install -y openstack-packstack
```

- Khởi động lại máy

```sh
init 6
```

 ##### Chuẩn bị trên Compute

 - Cài đặt IP và thiết lập mạng

 ```sh
 echo "Setup IP  eno49"
nmcli c modify eno49 ipv4.addresses 10.3.11.21/24
nmcli c modify eno49 ipv4.method manual

echo "Setup IP  eno53"
nmcli c modify eno53 ipv4.addresses 10.3.10.38/24
nmcli c modify eno53 ipv4.gateway 10.3.10.99
nmcli c modify eno53 ipv4.dns 8.8.8.8
nmcli c modify eno53 ipv4.method manual

sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/notify_only=1/notify_only=0/g' /etc/yum/pluginconf.d/search-disabled-repos.conf
````



- Đăng nhập vào controller và cài đặt repos cho Mitaka.

```sh
sudo yum install -y https://repos.fedorapeople.org/repos/openstack/openstack-mitaka/rdo-release-mitaka-6.noarch.rpm

yum update -y

sudo yum install -y wget crudini
yum install -y openstack-packstack
```

- Khởi động lại máy

```sh
init 6
```

#### Thực hiện cài đặt trên CONTROLLER

- Chuyển sang máy chủ controller để thực hiện bước tiếp theo

#### Cài đặt OpenStack

- Thực hiện lệnh dưới để cài trên controller, lệnh này sẽ tự động cài trên compute
- Lưu ý nhập đúng IP của các máy controller và compute
- Nếu có nhiều hơn 1 máy compute thì sử dụng dấu phẩy và các ip tiếp theo, ví dụ `--os-compute-hosts=10.3.10.37,10.3.10.38 ` 
- Lưu ý:
 - `eno49` : Được dùng để mapping openvswitch và card mạng vật lý của các máy chủ controller và compute
 - `eno53`: Được dùng để truyền thông giữu các máy ảo với nhau.

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
    --os-neutron-ovs-bridge-interfaces=br-ex:eno49 \
    --os-neutron-ovs-bridges-compute=br-ex \
    --os-neutron-ml2-type-drivers=vxlan,flat \
    --os-controller-host=10.3.10.37 \
    --os-compute-hosts=10.3.10.38 \
    --os-neutron-ovs-tunnel-if=eno53 \
    --provision-demo=n
```

#### Bước tạo network, máy ảo.

