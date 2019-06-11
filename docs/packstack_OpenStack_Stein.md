# Hương dẫn cài đặt OpenStack Stein bằng Packstack trên CENTOS 7.x


## 1. Các bước chuẩn bị
### 1.1. Giới thiệu

- Lưu ý: Trong tài liệu này chỉ thực hiện cài đặt OpenStack, bước cài đặt CEPH ở tài liệu khác.
- Packstack là một công cụ cài đặt OpenStack nhanh chóng.
- Packstack được phát triển bởi redhat
- Chỉ hỗ trợ các distro: RHEL, CentOS.
- Tự động hóa các bước cài đặt và lựa chọn thành phần cài đặt.
- Nhanh chóng dựng được môi trường OpenStack để sử dụng làm PoC nội bộ, demo khách hàng, test tính năng.
- Nhược điểm 1 : Đóng kín các bước cài đối với người mới.
- Nhược điểm 2: Khó bug các lỗi khi cài vì đã được đóng gói cùng với các tool cài đặt tự động (puppet).


### 1.2. Môi trường thực hiện 

- Sử dụng VMware Workstation hoặc KVM để tạo các máy cài đặt OpenStack - trong hướng dẫn này sẽ tạo trên KVM.
- Distro: CentOS 7.x
- OpenStack Stein
- Công cụ cài đặt: Packstack

### 1.3. Mô hình

![topology](../images/topology-openstack-stein.png)

Lưu ý:

- Trong mô hình này là mô hình gồm đầy đủ các node nhưng đối với hướng dẫn này chỉ cần có 03 node gồm: `Controller1, Compute1, Compute2`

### 1.4. IP Planning

![ipplanning](../images/ip-planning-openstack-stein.png)

- Lưu ý: 
  - Sử dụng đúng thứ tự các interface (NICs) của máy để cài đặt OpenStack.
  - Sử dụng đúng các dải địa chỉ IP.
	- Trong hướng dẫn này  không cần đặt IP cho eth2 vì không sử dụng CEPH.

## 2. Các bước cài đặt
### 2.1. Các bước chuẩn bị trên trên Controller

- Thiết lập hostname

	```sh
	hostnamectl set-hostname controller1
	```

- Thiết lập IP 

```sh
echo "Setup IP  eth0"
nmcli con modify eth0 ipv4.addresses 192.168.80.131/24
nmcli con modify eth0 ipv4.gateway 192.168.80.1
nmcli con modify eth0 ipv4.dns 8.8.8.8
nmcli con modify eth0 ipv4.method manual
nmcli con modify eth0 connection.autoconnect yes

echo "Setup IP  eth1"
nmcli con modify eth1 ipv4.addresses 192.168.81.131/24
nmcli con modify eth1 ipv4.method manual
nmcli con mod eth1 connection.autoconnect yes

echo "Setup IP  eth3"
nmcli con modify eth3 ipv4.addresses 192.168.84.131/24
nmcli con modify eth3 ipv4.method manual
nmcli con mod eth3 connection.autoconnect yes

sudo systemctl disable firewalld
sudo systemctl stop firewalld
sudo systemctl disable NetworkManager
sudo systemctl stop NetworkManager
sudo systemctl enable network
sudo systemctl start network

sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

echo "127.0.0.1   controller1 localhost" > /etc/hosts
echo "192.168.80.131   controller1" >> /etc/hosts
echo "192.168.80.132   compute1" >> /etc/hosts
echo "192.168.80.133   compute2" >> /etc/hosts

init 6
```
  
- Khai báo repos cho OpenStack Queens

	```sh
	yum install -y epel-release
	yum install -y centos-release-openstack-stein
	yum update -y

	yum install -y wget crudini  byobu
	yum install -y git python-setuptools
	yum install -y openstack-packstack
	```

- Trong queens khi sử dụng packstack để cài có thể gặp lỗi `ERROR : Failed to load plugin from file ssl_001.py`, fix theo hướng dẫn dưới (trong đoạn trên đã cài sẵn các fix rồi nhé)

	```sh
	https://gist.github.com/congto/36116ef868ee8fe2b2e83249710fee16
	```

### 2.2. Các bước chuẩn bị trên trên Compute1

- Thiết lập hostname

	```sh
	hostnamectl set-hostname compute1
	```

- Thiết lập IP 

	```sh
	echo "Setup IP  eth0"
	nmcli con modify eth0 ipv4.addresses 192.168.80.132/24
	nmcli con modify eth0 ipv4.gateway 192.168.80.1
	nmcli con modify eth0 ipv4.dns 8.8.8.8
	nmcli con modify eth0 ipv4.method manual
	nmcli con modify eth0 connection.autoconnect yes

	echo "Setup IP  eth1"
	nmcli con modify eth1 ipv4.addresses 192.168.81.132/24
	nmcli con modify eth1 ipv4.method manual
	nmcli con mod eth1 connection.autoconnect yes

	echo "Setup IP  eth3"
	nmcli con modify eth3 ipv4.addresses 192.168.84.132/24
	nmcli con modify eth3 ipv4.method manual
	nmcli con mod eth3 connection.autoconnect yes

	sudo systemctl disable firewalld
	sudo systemctl stop firewalld
	sudo systemctl disable NetworkManager
	sudo systemctl stop NetworkManager
	sudo systemctl enable network
	sudo systemctl start network

	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

	echo "127.0.0.1   compute1  localhost" > /etc/hosts
	echo "192.168.80.131   controller1" >> /etc/hosts
	echo "192.168.80.132   compute1" >> /etc/hosts
	echo "192.168.80.133   compute2" >> /etc/hosts

	init 6
	```

- Khai báo repos cho OpenStack Queens trên node `Compute1`

	```sh
	yum install -y epel-release
	yum install -y centos-release-openstack-stein
	yum update -y

	yum install -y wget crudini  byobu
	yum install -y git python-setuptools
	yum install -y openstack-packstack
	```
  
- Trong queens khi sử dụng packstack để cài có thể gặp lỗi `ERROR : Failed to load plugin from file ssl_001.py`, fix theo hướng dẫn dưới (trong đoạn trên đã cài sẵn các fix rồi nhé)
```sh
https://gist.github.com/congto/36116ef868ee8fe2b2e83249710fee16
```

### 2.3. Các bước chuẩn bị trên trên Compute2

- Thiết lập hostname
  ```sh
  hostnamectl set-hostname compute2
  ```

- Thiết lập IP 

	```sh
	echo "Setup IP  eth0"
	nmcli con modify eth0 ipv4.addresses 192.168.80.133/24
	nmcli con modify eth0 ipv4.gateway 192.168.80.1
	nmcli con modify eth0 ipv4.dns 8.8.8.8
	nmcli con modify eth0 ipv4.method manual
	nmcli con modify eth0 connection.autoconnect yes

	echo "Setup IP  eth1"
	nmcli con modify eth1 ipv4.addresses 192.168.81.133/24
	nmcli con modify eth1 ipv4.method manual
	nmcli con mod eth1 connection.autoconnect yes

	echo "Setup IP  eth3"
	nmcli con modify eth3 ipv4.addresses 192.168.84.133/24
	nmcli con modify eth3 ipv4.method manual
	nmcli con mod eth3 connection.autoconnect yes

	sudo systemctl disable firewalld
	sudo systemctl stop firewalld
	sudo systemctl disable NetworkManager
	sudo systemctl stop NetworkManager
	sudo systemctl enable network
	sudo systemctl start network

	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
	sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

	echo "127.0.0.1   compute2  localhost" > /etc/hosts
	echo "192.168.80.131   controller1" >> /etc/hosts
	echo "192.168.80.132   compute1" >> /etc/hosts
	echo "192.168.80.133   compute2" >> /etc/hosts

	init 6

	```

- Khai báo repos cho OpenStack Queens trên node `Compute2`

	```sh
	yum install -y epel-release
	yum install -y centos-release-openstack-stein
	yum update -y

	yum install -y wget crudini  byobu
	yum install -y git python-setuptools
	yum install -y openstack-packstack
	```

- Trong queens khi sử dụng packstack để cài có thể gặp lỗi `ERROR : Failed to load plugin from file ssl_001.py`, fix theo hướng dẫn dưới (trong đoạn trên đã cài sẵn các fix rồi nhé)

	```sh
	https://gist.github.com/congto/36116ef868ee8fe2b2e83249710fee16
	```

### 3. Cài đặt OpenStack Queens
#### 3.1. Chuẩn bị file trả lời cho packstack
- Đứng trên controller để thực hiện các bước sau
- Gõ lệnh dưới 
  ```sh
  byobu
  ```

- Tạo file trả lời để cài packstack
  ```sh
  packstack --gen-answer-file=/root/rdotraloi.txt \
    --allinone \
    --default-password=Welcome123 \
    --os-cinder-install=y \
    --os-ceilometer-install=n \
    --os-trove-install=n \
    --os-ironic-install=n \
    --os-swift-install=n \
    --os-panko-install=n \
    --os-heat-install=n \
    --os-magnum-install=n \
    --os-aodh-install=n \
    --os-neutron-ovs-bridge-mappings=extnet:br-ex \
    --os-neutron-ovs-bridge-interfaces=br-ex:eth3 \
    --os-neutron-ovs-bridges-compute=br-ex \
    --os-neutron-l2-agent=openvswitch \
    --os-neutron-ml2-type-drivers=vxlan,flat \
    --os-neutron-ml2-tenant-network-types=vxlan \
    --os-controller-host=192.168.80.131 \
    --os-compute-hosts=192.168.80.132,192.168.80.133 \
    --os-neutron-ovs-tunnel-if=eth1 \
    --provision-demo=n
  ```


  

- Thực thi file trả lời vừa tạo ở trên (nếu cần có thể mở ra để chỉnh lại các tham số cần thiết.

  ```sh
  packstack --answer-file rdotraloi.txt
  ```
  
- Nhập mật khẩu đăng nhập ssh của tài khoản root khi được yêu cầu.

- Chờ để packstack cài đặt xong.

####  3.2. Kiểm tra hoạt động của OpenStack sau khi cài 

- Sau khi cài đặt xong, màn hình sẽ hiển thị thông báo như dưới

  ```sh
	 **** Installation completed successfully ******

	Additional information:
	 * File /root/keystonerc_admin has been created on OpenStack client host 192.168.80.131. To use the command line tools you need to source the file.
	 * To access the OpenStack Dashboard browse to http://192.168.80.131/dashboard .
	Please, find your login credentials stored in the keystonerc_admin in your home directory.
	 * Because of the kernel update the host 192.168.80.131 requires reboot.
	 * Because of the kernel update the host 192.168.80.133 requires reboot.
	 * Because of the kernel update the host 192.168.80.132 requires reboot.
	 * The installation log file is available at: /var/tmp/packstack/20190609-151702-MVmefX/openstack-setup.log
	 * The generated manifests are available at: /var/tmp/packstack/20190609-151702-MVmefX/manifests
  ```

- Đứng trên `Controller1` thực hiện lệnh dưới để sửa các cấu hình cần thiết.

	```sh
	sed -i -e 's/enable_isolated_metadata=False/enable_isolated_metadata=True/g' /etc/neutron/dhcp_agent.ini

	ssh -o StrictHostKeyChecking=no root@192.168.80.132 "sed -i -e 's/compute1/192.168.80.132/g' /etc/nova/nova.conf"

	ssh -o StrictHostKeyChecking=no root@192.168.80.133 "sed -i -e 's/compute2/192.168.80.133/g' /etc/nova/nova.conf"
	```

- Tắt Iptables trên cả 03 node 

  ```sh 
	systemctl stop iptables
	systemctl disable iptables

	ssh -o StrictHostKeyChecking=no root@192.168.80.132 "systemctl stop iptables"
	ssh -o StrictHostKeyChecking=no root@192.168.80.132 "systemctl disable iptables"

	ssh -o StrictHostKeyChecking=no root@192.168.80.133 "systemctl stop iptables"
	ssh -o StrictHostKeyChecking=no root@192.168.80.133 "systemctl disable iptables"
	```

    
  
- Khởi động lại cả 03 node `Controller1, Compute1, Compute2`.

  ```sh
	ssh -o StrictHostKeyChecking=no root@192.168.80.132 "init 6"

	ssh -o StrictHostKeyChecking=no root@192.168.80.133 "init 6"

	init 6
  ```

- Đăng nhập lại vào `Controller1` bằng quyền `root` và kiểm tra hoạt động của openstack sau khi cài.
  - Khai báo biến môi trường
    ```sh
    source keystonerc_admin
    ```
  
  - Kiểm tra hoạt động của openstack bằng lệnh dưới (`lưu ý: có thể phải mất vài phút để các service của OpenStack khởi động xong`).
    ```sh
    openstack token issue
    ```
    
  - Kết quả lệnh trên như sau:
    ```sh
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | Field      | Value                                                                                                                                                                                   |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    | expires    | 2017-09-17T14:46:54+0000                                                                                                                                                                |
    | id         | gAAAAABZvnzOyW6-0gJLN5_ZG5zRpj932wYO5EgfvTWdJzU6HYxI1UpAl5_EHvSpU4pA5KWWHzVQkmKBKx0Pex8ZVxcSdBZGCDiJYrNCOd--0fqi80MBQzQuAH7ODATgR2-ZM7Or41Rq1M4dwC1rTLLWoqtiHuY2qJus9OUapJwbDfAivWHYCAk |
    | project_id | 2f8619d1fea2465cbe302eb74ed10d2e                                                                                                                                                        |
    | user_id    | 4487225f20454467bf89e21c1a04e921                                                                                                                                                        |
    +------------+-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
    ```

- Ngoài ra có thể kiểm tra thêm bằng cách lệnh khác: `openstack user list` ,  `openstack service list`, `openstack catalog list`

### 4. Tạo images, network, subnet, router, mở security group và tạo VM.
- Bước này có thể tạo bằng GUI hoặc bằng CLI
- Link truy cập vào web GUI là: 192.168.20.44. Đăng nhập với tài khoản là `admin`, mật khẩu là `Welcome123`

#### 4.1. Tạo images
- Đăng nhập vào node controller1 với quyền root và thực thi các lệnh sau
- Tải images cirros. Images này dùng để tạo các máy ảo sau này: 

  ```sh
  wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
  ```

- Tạo images 

  ```sh
  source keystonerc_admin

  openstack image create "cirros" \
    --file cirros-0.3.5-x86_64-disk.img \
    --disk-format qcow2 --container-format bare \
    --public
  ```

- Kiểm tra việc tạo images, kết quả như dưới là thành công. Nếu không có kết quả này thì chịu khó làm lại hoặc đọc log :) 

  ```sh
  openstack image list
  ```

#### 4.2. Tạo network

##### 4.2.1. Tạo provider network 

- Tạo provider network 

	```sh 
	openstack network create  --share --external \
		--provider-physical-network extnet \
		--provider-network-type flat net-provider
	```
	
- Taoh subnet cho provider network

	```sh
	openstack subnet create --network net-provider \
		--allocation-pool start=192.168.84.201,end=192.168.84.219 \
		--dns-nameserver 8.8.8.8 --gateway 192.168.84.1 \
		--subnet-range 192.168.84.0/24 sub-net-provider	
	```

##### 4.2.2. Tạo private network 
	
- Tạo private network 

	```sh
	openstack network create net-selfservice
	```

- Tạo subnet cho private network 

	```sh 
	openstack subnet create --network net-selfservice \
		--dns-nameserver 8.8.4.4 --gateway 172.199.1.1 \
		--subnet-range 172.199.1.0/24 sub-net-selfservice
	```	
	
##### 4.2.3. Tạo router

- Tạo router 

	```sh
	openstack router create R1
	```

- Gắn các private network vào Router, lệnh này ko hiển thị ra kết quả. Lưu ý điền đúng tên subnet private là `sub-net-selfservice` và tên của router là R1.

	```sh 
	openstack router add subnet R1 sub-net-selfservice
	```
	
- Gắn gateway cho router, bước này cũng cần điền đúng tên của network provider được tạo ở trên, đó là `net-provider`  và  và tên của router là R1.

	```sh
	openstack router set router --external-gateway net-provider	
	```

##### 4.3 Kiểm tra lại các bước thiết lập về network 


- Kiểm tra các agent của router và dhcp trên neutron bằng lệnh `ip netns`. Kết quả là: 

	```sh
	root@controller1 ~(keystone_admin)]# ip netns
	qrouter-4b831df7-470e-4be3-8775-56f2de9897cb (id: 2)
	qdhcp-0daa313c-2ea0-4be2-9d7f-546a2ae45715 (id: 1)
	qdhcp-4ac074cc-7055-4fb8-a101-aaba14b6cff4 (id: 0)
	```
	
- Kiểm tra các port của router R1

	```sh
	openstack port list --router R1
	```

- Kết quả là: 

	```sh
	+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+
	| ID                                   | Name | MAC Address       | Fixed IP Addresses                                                            | Status |
	+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+
	| c05caaed-5712-426e-8a3f-4e5bf9e5cd7c |      | fa:16:3e:4e:7a:b6 | ip_address='172.199.1.1', subnet_id='952a4b55-b6a5-4359-a758-be676e0a365a'    | ACTIVE |
	| f21af1b2-b58c-4d12-a5cf-d83623fc6d2c |      | fa:16:3e:51:02:92 | ip_address='192.168.84.219', subnet_id='e8e0a0f5-5df2-42f2-b030-fd063f8ec140' | ACTIVE |
	+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+
	```

- Lưu ý trong kết quả lệnh trên, ta sẽ thấy IP thuộc VLAN `192.168.84.0/24` là `192.168.84.219`. Đây chính là IP của router, nếu đứng từ máy bạn có thể ping tới IP này thì chứng tỏ việc thiết lập network đã thành công.

	```sh
	C:\Users\congto>ping 192.168.84.219

	Pinging 192.168.84.219 with 32 bytes of data:
	Reply from 192.168.84.219: bytes=32 time=17ms TTL=63
	Reply from 192.168.84.219: bytes=32 time=15ms TTL=63
	Reply from 192.168.84.219: bytes=32 time=16ms TTL=63
	Reply from 192.168.84.219: bytes=32 time=15ms TTL=63

	Ping statistics for 192.168.84.219:
			Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
	Approximate round trip times in milli-seconds:
			Minimum = 15ms, Maximum = 17ms, Average = 15ms
	```

##### 4.4. Mở các rule về security group

- Thực hiện mở các rule để có thể truy cập từ ngoài vào VM sau khi tạo xong VM ở các bước tiếp theo.

	```sh
	openstack security group rule create --proto icmp default
	openstack security group rule create --proto tcp --dst-port 22 default
	```

##### 4.5. Tạo VM	

- Cách 1: Truy cập vào dashboard ở địa chỉ http://192.168.80.131 để tạo VM.
- Cách 2: Sử dụng lệnh dưới để tạo VM.


	