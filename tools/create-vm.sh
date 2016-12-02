#!/bin/bash 

source ~/keystonerc_admin

echo "Tai image"
sleep 3
curl http://download.cirros-cloud.net/0.3.4/cirros-0.3.4-x86_64-disk.img | glance \
image-create --name='cirros' \
--visibility=public \
--container-format=bare \
--disk-format=qcow2

echo "Tao external network"
sleep 3
neutron net-create external_network --provider:network_type flat \
    --provider:physical_network extnet  \
    --router:external \
    --shared

echo "Tao subnet cho external network"
sleep 3
neutron subnet-create --name public_subnet \
    --enable_dhcp=True \
    --allocation-pool=start=172.16.69.80,end=172.16.69.100 \
    --gateway=172.16.69.1 external_network 172.16.69.0/24

echo "Tao private network"
sleep 3
neutron net-create private_network
    neutron subnet-create --name private_subnet private_network 10.0.0.0/24 \
    --dns-nameserver 8.8.8.8

echo "Tao router va gan cac interface cho router"
sleep 3
neutron router-create router
    neutron router-gateway-set router external_network
    neutron router-interface-add router private_subnet

echo "Tao cac rule trong security group"
sleep 3
openstack security group rule create --proto icmp default
openstack security group rule create --proto tcp --dst-port 22 default

echo "Ket thuc"