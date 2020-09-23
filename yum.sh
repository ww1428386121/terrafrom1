#!/bin/bash
#yum
yum -y update
yum -y install lrzsz httpd
systemctl start httpd
systemctl enable httpd
systemctl disable firewalld
echo hello world > /var/www/html/html.index