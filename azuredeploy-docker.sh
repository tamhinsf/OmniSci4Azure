# Credit to OmniSci for deployment script located here:
# https://github.com/omnisci/mapd_on_azure

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

apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Install Docker CE
#
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add - >> $LOG_PATH 2>&1

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable" >> $LOG_PATH 2>&1

apt-get update >> $LOG_PATH 2>&1
apt-get install -y docker-ce=18.03.0~ce-0~ubuntu >> $LOG_PATH 2>&1
usermod -aG docker $MAPD_USERNAME >> $LOG_PATH 2>&1

# Install nvidia-docker if necessary
#
if [ ! -z "$NVIDIA_GPU" ]
then
    curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
    apt-key add - >> $LOG_PATH 2>&1

    distribution=$(. /etc/os-release;echo $ID$VERSION_ID) >> $LOG_PATH 2>&1

    curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
    tee /etc/apt/sources.list.d/nvidia-docker.list >> $LOG_PATH 2>&1

    apt-get update >> $LOG_PATH 2>&1
    apt-get install -y nvidia-docker2 >> $LOG_PATH 2>&1
    pkill -SIGHUP dockerd >> $LOG_PATH 2>&1
fi

# Create the /mapd-storage data disk as a RAID 0
mkdir $MAPD_STORAGE >> $LOG_PATH 2>&1
if [ $NUM_OF_DATA_DISKS -eq 1 ]; then
  mkfs -t ext4 /dev/sdc >> $LOG_PATH 2>&1
  echo "UUID=`blkid -s UUID /dev/sdc | cut -d '"' -f2` $MAPD_STORAGE ext4  defaults,discard 0 0" | tee -a /etc/fstab >> $LOG_PATH 2>&1
else
  apt-get install lsscsi -y >> $LOG_PATH 2>&1
  DEVICE_NAME_STRING=
  for device in `lsscsi |grep -v "/dev/sda \|/dev/sdb \|/dev/sr0 " | cut -d "/" -f3`; do 
   DEVICE_NAME_STRING_TMP=`echo /dev/$device`
   DEVICE_NAME_STRING=`echo $DEVICE_NAME_STRING $DEVICE_NAME_STRING_TMP`
  done
  mdadm --create /dev/md0 --level 0 --raid-devices=$NUM_OF_DATA_DISKS $DEVICE_NAME_STRING >> $LOG_PATH 2>&1
  mkfs -t ext4 /dev/md0 >> $LOG_PATH 2>&1
  echo "UUID=`blkid -s UUID /dev/md0 | cut -d '"' -f2` $MAPD_STORAGE ext4  defaults,discard 0 0" | tee -a /etc/fstab >> $LOG_PATH 2>&1
fi

mount $MAPD_STORAGE >> $LOG_PATH 2>&1
chown -R $MAPD_USERNAME $MAPD_STORAGE >> $LOG_PATH 2>&1
chgrp -R $MAPD_USERNAME $MAPD_STORAGE >> $LOG_PATH 2>&1

# Setup startup in the user's crontab
sudo -u $MAPD_USERNAME crontab -l > $MAPD_STORAGE/mapd_start  >> $LOG_PATH 2>&1
if [ ! -z "$NVIDIA_GPU" ]
then
    sudo -u $MAPD_USERNAME echo "docker run --runtime=nvidia -v $MAPD_STORAGE/mapd-docker-storage:/mapd-storage -p 9090-9092:9090-9092 mapd/mapd-ce-cuda" >> $MAPD_STORAGE/StartMapD.sh 
else
    sudo -u $MAPD_USERNAME echo "docker run -d -v $MAPD_STORAGE/mapd-docker-storage:/mapd-storage -p 9090-9092:9090-9092 mapd/mapd-ce-cpu" >> $MAPD_STORAGE/StartMapD.sh 
fi
sudo -u $MAPD_USERNAME echo "@reboot bash $MAPD_STORAGE/StartMapD.sh &" >> $MAPD_STORAGE/mapd_start  
sudo -u $MAPD_USERNAME crontab $MAPD_STORAGE/mapd_start  >> $LOG_PATH 2>&1
sudo -u $MAPD_USERNAME rm $MAPD_STORAGE/mapd_start >> $LOG_PATH 2>&1

# Reboot to make sure updates register
#
shutdown -r +1 >> $LOG_PATH 2>&1
echo done >> $LOG_PATH 2>&1

# Exit script with 0 code to tell Azure that the deployment is done
exit 0 >> $LOG_PATH 2>&1


