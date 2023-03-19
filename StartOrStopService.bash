# command to start service
service httpd start

systemctl start httpd

# command to stop service
systemctl stop httpd

# check status of service
systemctl status httpd

#confighure service to start at startup
systemctl enable httpd

#confighure service to not start at startup
systemctl disable httpd

