#!/bin/bash

yum update -y
yum install java-1.8.0 -y
yum install java-17-amazon-corretto-devel.x86_64 -y
yum install wget -y
wget https://archive.apache.org/dist/kafka/3.4.0/kafka_2.13-3.4.0.tgz
tar -xzf kafka_2.13-3.4.0.tgz
rm kafka_2.13-3.4.0.tgz

cat > /home/ec2-user/bootstrap-servers <<- "EOF"
${bootstrap_server_1}
${bootstrap_server_2}
EOF

echo "PATH=$PATH:/bin:/usr/local/bin:/usr/bin:/kafka_2.13-3.4.0/bin" >> /home/ec2-user/.bash_profile

source ~/.bash_profile