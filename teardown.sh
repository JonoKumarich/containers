#!bin/bash

ip link delete veth0
ip netns delete netns0

for dir in dev proc sys; do
    umount "/home/container/overlay/merged/$dir"
done
umount "/home/container/overlay/merged"

rm -r /home/container/overlay/
