## Hướng dẫn cấu hình các cơ chế Teaming và Bonding trong CENTOS - RHEL

## Hướng dẫn cấu hình bonding trên RHEL
### Mô hình và môi trường thực hiện
- Môi trường thực hiện: RHEL 7.x
- Phân bố các NICs:
	- team0: `eno16777728` & `eno33554952`, sử dụng VMnet10 
	- team1: `eno50332192` & `eno67109416`, sử dụng NAT

- Trong bài LAB này sẽ thực hiện bonding 2 cặp NICs của các máy chủ.

### Các bước cấu hình

- Thực hiện lệnh dưới để nạp chế độ bonding cho OS trên tất cả các máy cần cấu hình
	```sh
	modprobe bonding
	```

- Kiểm tra lại xem mode bonding đã được nạp hay chưa
	```sh
	modinfo bonding
	```

	- Kết quả sẽ hiện thị như dưới, trong đó chứa dòng `description:    Ethernet Channel Bonding Driver, v3.7.1`

		```sh
		[root@rhel7-srv2 network-scripts]# modinfo bonding
		filename:       /lib/modules/3.10.0-327.el7.x86_64/kernel/drivers/net/bonding/bonding.ko
		author:         Thomas Davis, tadavis@lbl.gov and many others
		description:    Ethernet Channel Bonding Driver, v3.7.1
		version:        3.7.1
		license:        GPL
		alias:          rtnl-link-bond
		rhelversion:    7.2
		srcversion:     5ACA30A256544B84A47E606
		depends:
		intree:         Y
		vermagic:       3.10.0-327.el7.x86_64 SMP mod_unload modversions
		signer:         Red Hat Enterprise Linux kernel signing key
		sig_key:        BC:73:C3:CE:E8:9E:5E:AE:99:4A:E5:0A:0D:B1:F0:FE:E3:FC:09:13
		sig_hashalgo:   sha256
		parm:           max_bonds:Max number of bonded devices (int)
		parm:           tx_queues:Max number of transmit queues (default = 16) (int)
		parm:           num_grat_arp:Number of peer notifications to send on failover event (alias of num_unsol_na) (int)
		parm:           num_unsol_na:Number of peer notifications to send on failover event (alias of num_grat_arp) (int)
		parm:           miimon:Link check interval in milliseconds (int)
		parm:           updelay:Delay before considering link up, in milliseconds (int)
		parm:           downdelay:Delay before considering link down, in milliseconds (int)
		parm:           use_carrier:Use netif_carrier_ok (vs MII ioctls) in miimon; 0 for off, 1 for on (default) (int)
		parm:           mode:Mode of operation; 0 for balance-rr, 1 for active-backup, 2 for balance-xor, 3 for broadcast, 4 for 802.3ad, 5 for balance-tlb, 6 for balance-alb (charp)
		parm:           primary:Primary network device to use (charp)
		parm:           primary_reselect:Reselect primary slave once it comes up; 0 for always (default), 1 for only if speed of primary is better, 2 for only on active slave failure (charp)
		parm:           lacp_rate:LACPDU tx rate to request from 802.3ad partner; 0 for slow, 1 for fast (charp)
		parm:           ad_select:803.ad aggregation selection logic; 0 for stable (default), 1 for bandwidth, 2 for count (charp)
		parm:           min_links:Minimum number of available links before turning on carrier (int)
		parm:           xmit_hash_policy:balance-xor and 802.3ad hashing method; 0 for layer 2 (default), 1 for layer 3+4, 2 for layer 2+3, 3 for encap layer 2+3, 4 for encap layer 3+4 (charp)
		parm:           arp_interval:arp interval in milliseconds (int)
		parm:           arp_ip_target:arp targets in n.n.n.n form (array of charp)
		parm:           arp_validate:validate src/dst of ARP probes; 0 for none (default), 1 for active, 2 for backup, 3 for all (charp)
		parm:           arp_all_targets:fail on any/all arp targets timeout; 0 for any (default), 1 for all (charp)
		parm:           fail_over_mac:For active-backup, do not set all slaves to the same MAC; 0 for none (default), 1 for active, 2 for follow (charp)
		parm:           all_slaves_active:Keep all frames received on an interface by setting active flag for all slaves; 0 for never (default), 1 for always. (int)
		parm:           resend_igmp:Number of IGMP membership reports to send on link failure (int)
		parm:           packets_per_slave:Packets to send per slave in balance-rr mode; 0 for a random slave, 1 packet per slave (default), >1 packets per slave. (int)
		parm:           lp_interval:The number of seconds between instances where the bonding driver sends learning packets to each slaves peer switch. The default is 1. (uint)
		````
#### Các bước cấu hình bond0

- Bước 1: Tạo interface bond0 cho 2 interface `eno16777728` & `eno33554952`
	```sh
	cat << EOF> /etc/sysconfig/network-scripts/ifcfg-bond0
	DEVICE=bond0
	TYPE=Bond
	NAME=bond0
	BONDING_MASTER=yes
	BOOTPROTO=none
	ONBOOT=yes
	IPADDR=10.10.10.41
	NETMASK=255.255.255.0
	BONDING_OPTS="mode=5 miimon=100"
	EOF
	```

- Bước 2: Sửa lại cấu hình của các interface thuộc bond0
	- Sao lưu file cấu hình của interface `eno16777728`
		```sh
		cp /etc/sysconfig/network-scripts/ifcfg-eno16777728 /etc/sysconfig/network-scripts/ifcfg-eno16777728.orig
		```

	- Sửa dòng với giá trị mới nếu đã có dòng đó và thêm các dòng nếu thiếu trong file `/etc/sysconfig/network-scripts/ifcfg-eno16777728`
		```sh
		BOOTPROTO=none
		ONBOOT=yes
		MASTER=bond0
		SLAVE=yes
		```

	- Sao lưu file cấu hình của interface `eno33554952`
		```sh
		cp /etc/sysconfig/network-scripts/ifcfg-eno33554952 /etc/sysconfig/network-scripts/ifcfg-eno33554952.orig
		```

	- Sửa dòng với giá trị mới nếu đã có dòng đó và thêm các dòng nếu thiếu trong file `/etc/sysconfig/network-scripts/ifcfg-eno33554952`
		```sh
		BOOTPROTO=none
		ONBOOT=yes
		MASTER=bond0
		SLAVE=yes
		```

	- Khởi động lại network sau khi cấu hình bond0
		```sh
		nmcli con reload
		systemctl restart network
		```

	- Kiểm tra lại địa chỉ IP `ip a` ta sẽ thấy `bond0` có địa chỉ IP, các card còn lại sau khi bond sẽ ko có.

#### Các bước cấu hình bond1

- Bước 1: Tạo interface bond1 cho 2 interface `eno50332192` & `eno67109416`
	```sh
	cat << EOF> /etc/sysconfig/network-scripts/ifcfg-bond1
	DEVICE=bond1
	TYPE=Bond
	NAME=bond1
	BONDING_MASTER=yes
	BOOTPROTO=none
	ONBOOT=yes
	IPADDR=172.16.69.41
	NETMASK=255.255.255.0
	GATEWAY=172.16.69.1
	BONDING_OPTS="mode=5 miimon=100"
	EOF
	```

- Bước 2: Sửa lại cấu hình của các interface thuộc bond1
	- Sao lưu file cấu hình của interface `eno50332192`
		```sh
		cp /etc/sysconfig/network-scripts/ifcfg-eno50332192 /etc/sysconfig/network-scripts/ifcfg-eno50332192.orig
		```

	- Sửa dòng với giá trị mới nếu đã có dòng đó và thêm các dòng nếu thiếu trong file `/etc/sysconfig/network-scripts/ifcfg-eno50332192`
		```sh
		BOOTPROTO=none
		ONBOOT=yes
		MASTER=bond1
		SLAVE=yes
		```

	- Sao lưu file cấu hình của interface `eno67109416`
		```sh
		cp /etc/sysconfig/network-scripts/ifcfg-eno67109416 /etc/sysconfig/network-scripts/ifcfg-eno67109416.orig
		```

	- Sửa dòng với giá trị mới nếu đã có dòng đó và thêm các dòng nếu thiếu trong file `/etc/sysconfig/network-scripts/ifcfg-eno67109416`, các dòng khác giữu nguyên
		```sh
		BOOTPROTO=none
		ONBOOT=yes
		MASTER=bond1
		SLAVE=yes
		```

	- Khởi động lại network sau khi cấu hình bond0
		```sh
		nmcli con reload
		systemctl restart network
		```

	- Kiểm tra lại địa chỉ IP `ip a` ta sẽ thấy `bond1` có địa chỉ IP, các card còn lại sau khi bond sẽ ko có.


- Kết quả cuối cùng ta có 02 bond, để kiểm tra trạng thái bonding ta sử dụng lệnh `cat /proc/net/bonding/bond0`. Kết quả như dưới:

	```sh
	[root@rhel7-srv2 ~]# cat /proc/net/bonding/bond0
	Ethernet Channel Bonding Driver: v3.7.1 (April 27, 2011)

	Bonding Mode: transmit load balancing
	Primary Slave: None
	Currently Active Slave: eno33554952
	MII Status: up
	MII Polling Interval (ms): 100
	Up Delay (ms): 0
	Down Delay (ms): 0

	Slave Interface: eno16777728
	MII Status: up
	Speed: 1000 Mbps
	Duplex: full
	Link Failure Count: 1
	Permanent HW addr: 00:0c:29:52:d8:e4
	Slave queue ID: 0

	Slave Interface: eno33554952
	MII Status: up
	Speed: 1000 Mbps
	Duplex: full
	Link Failure Count: 0
	Permanent HW addr: 00:0c:29:52:d8:ee
	Slave queue ID: 0
	```

### Sử dụng các lệnh sau để test các mode của bonding

- Sử dụng lệnh watch với netstat, sau đó đứng từ một máy khác ping đến và quan sát kết quả.
	```sh
	watch -d -n1 netstat -i
	```
  
# Câu hình bonding = lệnh ncmli 

- Cấu hình bond (bond0 là sự kết hợp của `eno16777728` và `eno33554952`)
```sh
nmcli con add type bond con-name bond0 ifname bond0 mode active-backup

nmcli con add type bond-slave con-name bond0-eno16777728 ifname eno16777728 master bond0

nmcli con add type bond-slave con-name bond0-eno33554952 ifname eno33554952 master bond0

nmcli con up bond0-eno16777728

nmcli con up bond0-eno33554952

nmcli con up
```

- Đặt IP cho `bond0`
```sh
nmcli c modify bond0 ipv4.addresses 10.10.10.99/24
nmcli c modify bond0 ipv4.gateway 10.10.10.1
nmcli c modify bond0 ipv4.dns 8.8.8.8
nmcli c modify bond0 ipv4.method manual
nmcli con mod bond0 connection.autoconnect yes
```




### Các trang tham khảo

- Cách sử dụng nmcli: http://linoxide.com/linux-command/nmcli-tool-red-hat-centos-7/
- Lệnh để test bonding: http://www.tecmint.com/configure-network-bonding-or-teaming-in-rhel-centos-7/
- Cấu hình teaming và bonding https://www.lisenet.com/2016/configure-aggregated-network-links-on-rhel-7-bonding-and-teaming/