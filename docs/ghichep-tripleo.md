# Các ghi chép khi cài đặt RDO - tripleo


- Thiết lập hostname

    ```sh
    hostnamectl set-hostname tripleo
    ```

- Thiết lập IP 

    ```sh
    echo "Setup IP  ens192"
    nmcli c modify ens192 ipv4.addresses 172.16.20.54/24
    nmcli c modify ens192 ipv4.method manual
    nmcli con mod ens192 connection.autoconnect yes 

    echo "Setup IP  ens160"
    nmcli c modify ens160 ipv4.addresses 192.168.20.54/24
    nmcli c modify ens160 ipv4.gateway 192.168.20.254
    nmcli c modify ens160 ipv4.dns 8.8.8.8
    nmcli c modify ens160 ipv4.method manual
    nmcli con mod ens160 connection.autoconnect yes

    sudo systemctl disable firewalld
    sudo systemctl stop firewalld
    sudo systemctl disable NetworkManager
    sudo systemctl stop NetworkManager
    sudo systemctl enable network
    sudo systemctl start network

    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
    sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

    wget http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
    rpm -ivh epel-release-7-9.noarch.rpm

    sudo yum install byobu -y --enablerepo=epel-testing


    init 6
    ```