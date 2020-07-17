# Setup LB name resolution using /etc/hosts file
# IP address and name of the LB front end 
echo "192.168.0.4 sid-NFS" >> /etc/hosts

# Create the root NFS export entry
sudo sh -c 'echo /srv/nfs/ *\(rw,no_root_squash,fsid=0\)>/etc/exports'
sudo mkdir /srv/nfs/

# Install drbd components
sudo zypper install -y drbd drbd-kmp-default drbd-utils

#listamos los discos para crear las particiones. Esto se debe repetir por cada disco a montar
ls /dev/disk/azure/scsi1/
# mejor con variables ;)
lun0="/dev/disk/azure/scsi1/lun0"
sudo sh -c "echo -e 'n\n\n\n\n\nw\n' | fdisk $lun0"

# una vez creadas las particiones, creamos los volumenes con LVM
ls /dev/disk/azure/scsi1/lun*-part*
# mejor con variables ;)
part1="/dev/disk/azure/scsi1/lun0-part1"
sudo pvcreate $part1
# Y el volume group con el SID del SAP para el que estamos desplegando  
sudo vgcreate vg-SID-NFS $part1 
#y ahora el Logical Volume sobre ese Volume Group
sudo lvcreate -l 100%FREE -n SID vg-SID-NFS

# Configure drbd. Aquí verificamos que el archivo incluye las líneas 
# include "drbd.d/global_common.conf";
# include "drbd.d/*.res";
drbd=$(cat /etc/drbd.conf | grep 'include "drbd.d/')
echo $drbd

# añadimos las líneas en el archivo /etc/drbd.d/global_common.conf si no están
# sigo buscando la forma de añadir las líneas pero me fallan las que tienen /
# puedes usar vi para añadirlas en cada sección

global {
     usage-count no;
}
common {
     handlers {
          fence-peer "/usr/lib/drbd/crm-fence-peer.sh";
          after-resync-target "/usr/lib/drbd/crm-unfence-peer.sh";
          split-brain "/usr/lib/drbd/notify-split-brain.sh root";
          pri-lost-after-sb "/usr/lib/drbd/notify-pri-lost-after-sb.sh; /usr/lib/drbd/notify-emergency-reboot.sh; echo b > /proc/sysrq-trigger ; reboot -f";
     }
     startup {
          wfc-timeout 0;
     }
     options {
     }
     disk {
          md-flushes yes;
          disk-flushes yes;
          c-plan-ahead 1;
          c-min-rate 100M;
          c-fill-target 20M;
          c-max-rate 4G;
     }
     net {
          after-sb-0pri discard-younger-primary;
          after-sb-1pri discard-secondary;
          after-sb-2pri call-pri-lost-after-sb;
          protocol     C;
          tcp-cork yes;
          max-buffers 20000;
          max-epoch-size 20000;
          sndbuf-size 0;
          rcvbuf-size 0;
     }
}

# Create the NFS drbd devices
# añadimos el contenido al archivo /etc/drbd.d/NW1-nfs.res
# cambiamos por nuestros hostnames, IPs y el nombre de los volumenes que creamos

resource SID-nfs {
     protocol     C;
     disk {
          on-io-error       detach;
     }
     on pacemaker1 {
          address   192.168.0.10:7790;
          device    /dev/drbd0;
          disk      /dev/vg-SID-NFS/SID;
          meta-disk internal;
     }
     on pacemaker2 {
          address   192.168.0.11:7790;
          device    /dev/drbd0;
          disk      /dev/vg-SID-NFS/SID;
          meta-disk internal;
     }
}

# Create the drbd device and start it
sudo drbdadm create-md SID-nfs
sudo drbdadm up SID-nfs

