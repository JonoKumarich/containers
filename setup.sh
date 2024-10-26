#!bin/bash

set -e

cd /home/container

i=1
for layer in $(jq -r '.[0].Layers[]' image/manifest.json); do
    mkdir -p overlay/layers/layer_$i
    tar -xf image/$layer -C overlay/layers/layer_$i
    ((i++))
done

mkdir overlay/upper
mkdir overlay/merged
mkdir overlay/work

lowerdir=$(ls -d -1 overlay/layers/* | tac | paste -sd ':' -)

sudo mount -t overlay overlay \
    -o lowerdir="$lowerdir",upperdir=overlay/upper,workdir=overlay/work overlay/merged

for dir in dev proc sys; do
    sudo mount --bind /$dir "overlay/merged/$dir"
done

ip netns add netns0

ip link add veth0 type veth peer name ceth0
ip link set ceth0 netns netns0
ip link set veth0 up

ip addr add 172.18.0.11/16 dev veth0

ip netns exec netns0 ip addr add 172.18.0.10/16 dev ceth0

ip netns exec netns0 ip link set ceth0 up
ip netns exec netns0 ip link set lo up  

ip netns exec netns0 ip route add default via 172.18.0.11

iptables -t nat -A PREROUTING -d 10.0.2.2 -p tcp --dport 8000 -j DNAT --to-destination 172.18.0.10:8000
iptables -t nat -A POSTROUTING -s 172.18.0.0/16 -j MASQUERADE



ip netns exec netns0 chroot /home/container/overlay/merged /bin/bash

