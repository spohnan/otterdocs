install
text
skipx
keyboard us
lang en_US
timezone  Etc/UTC
auth  --useshadow  --enablemd5
bootloader --location=mbr
firewall --enabled --port=22:tcp
firstboot --disable
network --device eth0 --bootproto dhcp
rootpw --iscrypted $1$xHUoQCg9$b5Ngf3/vhIjeGaBD84puX1
selinux --enforcing

reboot

# Disk Recepie
# Reset partitions
zerombr
clearpart --all --initlabel

# Partition into boot and everything else
part /boot --fstype=ext4 --size=200
part pv.2 --size=1 --grow
# Set up lvm
volgroup VolGroup --pesize=4096 pv.2
logvol / --fstype=ext4 --name=lv_root --vgname=VolGroup --grow --size=1024
logvol swap --name=lv_swap --vgname=VolGroup --size=2048
# This may need some adjusting, trying to get rid of "Finding: Audit is not separated from critical system partitions."
# Source is http://www.nsa.gov/ia/_files/os/redhat/rhel5-guide-i731.pdf ~ page 18
logvol /var/log --fstype=ext4 --name=lv_log --vgname=VolGroup --grow --percent=3 --maxsize=10240
logvol /var/log/audit --fstype=ext4 --name=lv_audit --vgname=VolGroup --grow --percent=3 --maxsize=10240

%packages --nobase
@core
screen
git
vim-enhanced
acpid

%post
(

# Needs to be running to hear virtsh shutdown commands
/sbin/chkconfig acpid on

# Just don't like to wait ;)
sed -i 's/timeout=5/timeout=0/' /etc/grub.conf

# Create ssh key for root user
ssh-keygen -t rsa

# Add the public key to my laptop account as an authorized user of the system
echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+YXXQ+LuE2eQSCwrnqsuef6yYRWNGL30w2rRn7CyXsjJ9YA0bvTO6CT7JOOjS1T2m6JD0bhku2bDYYaSNt1elfY+0XlQY7O9R83YSbvxevND7CD1u08wq1+VHDTWPfHf+spokU+G0qwshjaE0ZSIcx86va2RAIa8mQbvFsk6TU0fIU2u6Tx3Lea8ABQfCEGR0u9CYauL1ORZDdh0wUuF3oqL1JUm6OuB6HsigE2glx0dFbSvRAhJygaTine0PXQ6yhnEjvRt5mzxK2e4Qsu+r5lQqQfLKZz+nW22SHNwex8tFdh5o31oO3kmFKip+rkA9X1dVUDpWkhSEExGbp3ft andy@Andrews-MacBook-Pro-2.local" >> /root/.ssh/authorized_keys
chmod 600 authorized_keys

# Add our local repos as preferred
echo "
[local-base]
name=CentOS-Local - Base
baseurl=http://192.168.100.2/repo/CentOS/6/os/x86_64/
gpgcheck=0
cost=1

[local-updates]
name=CentOS-Local - Updates
baseurl=http://192.168.100.2/repo/CentOS/6/updates/x86_64/
gpgcheck=0
cost=1
" > /etc/yum.repos.d/CentOS-Local.repo

# Add repo for other useful utils
rpm -Uvh http://download.fedoraproject.org/pub/epel/6/i386/epel-release-6-7.noarch.rpm
