# Log activity
LOG_PATH=/tmp/azuredeploy.log

# Log parameters passed to this script. 
echo $@ >> $LOG_PATH 2>&1

# Store parameters passed to this script
NUM_OF_DATA_DISKS=${1}

# Basic info
date > $LOG_PATH 2>&1
whoami >> $LOG_PATH 2>&1

# Set the storage area for MapD
MAPD_STORAGE=/mapd-storage

# Setup the mapd user
MAPD_USERNAME=mapd
useradd -U $MAPD_USERNAME >> $LOG_PATH 2>&1

# Check if we have a NVIDIA GPU
NVIDIA_GPU=`lspci | grep NVIDIA`
if [ ! -z "$NVIDIA_GPU" ]
then
    echo NVIDIA GPU Detected $NVIDIA_GPU >> $LOG_PATH 2>&1
else
    echo No NVIDIA GPU Detected >> $LOG_PATH 2>&1
fi

# Create the /mapd-storage data disk as a RAID 0
mkdir $MAPD_STORAGE >> $LOG_PATH 2>&1
if [ $NUM_OF_DATA_DISKS -eq 1 ]; then
  mkfs -F -t ext4 /dev/sdc >> $LOG_PATH 2>&1
  echo "UUID=`blkid -s UUID /dev/sdc | cut -d '"' -f2` $MAPD_STORAGE ext4  defaults,discard 0 0" | tee -a /etc/fstab >> $LOG_PATH 2>&1
else
  apt-get install lsscsi -y >> $LOG_PATH 2>&1
  DEVICE_NAME_STRING=
  for device in `lsscsi |grep -v "/dev/sda \|/dev/sdb \|/dev/sr0 " | cut -d "/" -f3`; do 
   DEVICE_NAME_STRING_TMP=`echo /dev/$device`
   DEVICE_NAME_STRING=`echo $DEVICE_NAME_STRING $DEVICE_NAME_STRING_TMP`
  done
  mdadm --create /dev/md0 --level 0 --raid-devices=$NUM_OF_DATA_DISKS $DEVICE_NAME_STRING >> $LOG_PATH 2>&1
  mkfs -F -t ext4 /dev/md0 >> $LOG_PATH 2>&1
  echo "UUID=`blkid -s UUID /dev/md0 | cut -d '"' -f2` $MAPD_STORAGE ext4  defaults,discard 0 0" | tee -a /etc/fstab >> $LOG_PATH 2>&1
fi

mount $MAPD_STORAGE >> $LOG_PATH 2>&1
chown -R $MAPD_USERNAME $MAPD_STORAGE >> $LOG_PATH 2>&1
chgrp -R $MAPD_USERNAME $MAPD_STORAGE >> $LOG_PATH 2>&1

if [ ! -z "$NVIDIA_GPU" ]
then
    echo NVIDIA GPU Detected $NVIDIA_GPU >> $LOG_PATH 2>&1
    curl https://releases.mapd.com/ce/mapd-ce-cuda.repo | tee /etc/yum.repos.d/mapd.repo >> $LOG_PATH 2>&1
    yum install mapd -y >> $LOG_PATH 2>&1
else
    echo No NVIDIA GPU Detected >> $LOG_PATH 2>&1
    curl https://releases.mapd.com/ce/mapd-ce-cpu.repo | tee /etc/yum.repos.d/mapd.repo >> $LOG_PATH 2>&1
    yum install mapd -y >> $LOG_PATH 2>&1
fi

MAPD_USERNAME_HOME=`eval echo ~$MAPD_USERNAME`
echo "export MAPD_USER=$MAPD_USERNAME" >> $MAPD_USERNAME_HOME/.bashrc
echo "export MAPD_GROUP=$MAPD_USERNAME" >> $MAPD_USERNAME_HOME/.bashrc
echo "export MAPD_PATH=/opt/mapd" >> $MAPD_USERNAME_HOME/.bashrc
echo "export MAPD_STORAGE=$MAPD_STORAGE" >> $MAPD_USERNAME_HOME/.bashrc
echo "export MAPD_LOG=$MAPD_STORAGE/data/mapd_log" >> $MAPD_USERNAME_HOME/.bashrc

rm /tmp/install_mapd_systemd
echo /opt/mapd >> /tmp/install_mapd_systemd
echo $MAPD_STORAGE >> /tmp/install_mapd_systemd
echo $MAPD_USERNAME >> /tmp/install_mapd_systemd
echo $MAPD_USERNAME >> /tmp/install_mapd_systemd

cd /opt/mapd/systemd >> $LOG_PATH 2>&1
./install_mapd_systemd.sh < /tmp/install_mapd_systemd >> $LOG_PATH 2>&1
rm /tmp/install_mapd_systemd

cd $MAPD_PATH
systemctl start mapd_server >> $LOG_PATH 2>&1
systemctl start mapd_web_server >> $LOG_PATH 2>&1
systemctl enable mapd_server >> $LOG_PATH 2>&1
systemctl enable mapd_web_server >> $LOG_PATH 2>&1

# Reboot to make sure updates register
#
shutdown -r +1 >> $LOG_PATH 2>&1
echo done >> $LOG_PATH 2>&1

# Exit script with 0 code to tell Azure that the deployment is done
exit 0 >> $LOG_PATH 2>&1