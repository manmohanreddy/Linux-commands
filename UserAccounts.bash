# useradd: To create a new user account called "john", you can use the following command:
sudo useradd john

# userdel: To delete the user account "john", you can use the following command:
sudo userdel john

# passwd: To change the password of the user account "john", you can use the following command:
sudo passwd john

# su: To switch to the user account "john", you can use the following command:
su john


# sudo: To execute a command with superuser privileges, you can use the following command:
sudo command

#id: To display the UID and GID of the user account "john", you can use the following command:
id john

# groups: To display the groups that the user account "john" belongs to, you can use the following command:

groups john

# chown: To change the ownership of a file called "file.txt" to the user "john", you can use the following command:
sudo chown john file.txt

# chgrp: To change the group ownership of a file called "file.txt" to the group "staff", you can use the following command:

sudo chgrp staff file.txt

# usermod: To add the user "john" to the group "staff", you can use the following command:

sudo usermod -aG staff john

# whoami: To display the current user's username, you can use the following command:

whoami

# finger: To display information about the user account "john", you can use the following command:

finger john

# last: To display the last logged in users, you can use the following command:
last

# w: To display the users who are currently logged in, you can use the following command:

w

# adduser: To create a new user account called "john" with a home directory and a default set of configuration files, you can use the following command:
sudo adduser john
