# Skip initial synchronization
sudo drbdadm new-current-uuid --clear-bitmap SID-nfs

# Set the primary node
sudo drbdadm primary --force SID-nfs

# Wait until the new drbd devices are synchronized
sudo drbdsetup wait-sync-resource SID-nfs

# Create file systems on the drbd devices
sudo mkfs.xfs /dev/drbd0
sudo mkdir /srv/nfs/SID
sudo chattr +i /srv/nfs/SID
sudo mount -t xfs /dev/drbd0 /srv/nfs/SID
sudo mkdir /srv/nfs/SID/sidsys
sudo mkdir /srv/nfs/SID/sapmntsid
sudo mkdir /srv/nfs/SID/trans
sudo mkdir /srv/nfs/SID/ASCS
sudo mkdir /srv/nfs/SID/ASCSERS
sudo mkdir /srv/nfs/SID/SCS
sudo mkdir /srv/nfs/SID/SCSERS
sudo umount /srv/nfs/SID

# empezamos cambiando la configuración del crm
sudo crm configure rsc_defaults resource-stickiness="200"

# Enable maintenance mode.
# Antes de cambiar nada siempre hay que entrar en modo mantenimiento
sudo crm configure property maintenance-mode=true

#  Add the NFS drbd devices for SAP system SID to the cluster configuration
# esta parte es la más importante, ya que creas los recursos del cluster
sudo crm configure primitive drbd_SID_nfs \
  ocf:linbit:drbd \
  params drbd_resource="SID-nfs" \
  op monitor interval="15" role="Master" \
  op monitor interval="30" role="Slave"

sudo crm configure ms ms-drbd_SID_nfs drbd_SID_nfs \
  meta master-max="1" master-node-max="1" clone-max="2" \
  clone-node-max="1" notify="true" interleave="true"

sudo crm configure primitive fs_SID_sapmnt \
  ocf:heartbeat:Filesystem \
  params device=/dev/drbd0 \
  directory=/srv/nfs/SID  \
  fstype=xfs \
  op monitor interval="10s"

sudo crm configure primitive nfsserver systemd:nfs-server \
  op monitor interval="30s"
sudo crm configure clone cl-nfsserver nfsserver

sudo crm configure primitive exportfs_SID \
  ocf:heartbeat:exportfs \
  params directory="/srv/nfs/SID" \
  options="rw,no_root_squash,crossmnt" clientspec="*" fsid=1 wait_for_leasetime_on_stop=true op monitor interval="30s"

#en este punto configuras la IP del balanceador
sudo crm configure primitive vip_SID_nfs \
  IPaddr2 \
  params ip=192.168.0.4 cidr_netmask=24 op monitor interval=10 timeout=20

#aquí configuras el probe port que has usando en el balanceador
sudo crm configure primitive nc_SID_nfs azure-lb port=61000

sudo crm configure group g-SID_nfs \
  fs_SID_sapmnt exportfs_SID nc_SID_nfs vip_SID_nfs

sudo crm configure order o-SID_drbd_before_nfs inf: \
  ms-drbd_SID_nfs:promote g-SID_nfs:start

sudo crm configure colocation col-SID_nfs_on_drbd inf: \
  g-SID_nfs ms-drbd_SID_nfs:Master

# arrancamos el cluster
sudo crm configure property maintenance-mode=false