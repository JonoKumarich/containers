#!bin/bash

echo "working"
set -e

mkdir /home/container
cd /home/container

mkdir image
cd image

docker pull python:3.11
docker save python:3.11 > output.tar

tar -xvf output.tar
rm output.tar

