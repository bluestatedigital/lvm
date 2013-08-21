# Cookbook Name:: lvm
# Recipe:: ec2-clusterdb-lvm-ephemeral

include_recipe 'lvm'

pod_std = '/dev/mapper/vg0-data1'
pod_bak = '/dev/mapper/vgbackup-lvbackup'
devs = ['/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde'].sort

begin
  # already a standard db pod
  return if node[:filesystem][pod_std]
rescue ArgumentError
  begin
    # already a backup db pod
    return if node[:filesystem][pod_bak]
  rescue ArgumentError
  end
end

mount devs[0] do
  device devs[0]
  action [:umount, :disable]
end
bash "unmount_default_ephemeral" do
  code <<-EOH
    umount /media/ephemeral0
  EOH
  user "root"
  cwd "/tmp"
  only_if "df | grep sdb"
end

lvm_volume_group 'vg0' do
  physical_volumes devs
  logical_volume 'data1' do
    size '85%VG'
    filesystem 'ext4'
    mount_point :location => '/media/ephemeral0',
                :options => 'noatime,nodiratime',
                :dump => '0',
                :pass => '2'
    stripes devs.count
  end
end

mount "/media/ephemeral0" do
  device "/dev/mapper/vg0-data1"
  fstype "ext4"
  options "rw,noatime,nodiratime"
  action [:mount, :enable]
end
bash "mount_default_ephemeral" do
  code <<-EOH
    mount -t ext4 -O rw,noatime,nodiratime /dev/mapper/vg0-data1 /media/ephemeral0
  EOH
  user "root"
  cwd "/tmp"
  not_if "df | grep vg0-data1"
end


