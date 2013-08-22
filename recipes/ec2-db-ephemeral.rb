# Cookbook Name:: lvm
# Recipe:: ec2-db-ephemeral

include_recipe 'lvm'
devs = ['/dev/xvdb', '/dev/xvdc', '/dev/xvdd', '/dev/xvde'].sort

# do nothing if volume group already present
unless %x{df} =~ /vg(0|backup)-(data1|lvbackup)/

  mount "disable_default_ephemeral" do
    action :disable
    device "/dev/xvdb"
  end

  bash "unmount_default_ephemeral" do
    code <<-EOH
      umount /dev/xvdb
    EOH
    user "root"
    cwd "/tmp"
    only_if "df | grep xvdb"
  end

  lvm_volume_group 'vg0' do
    physical_volumes devs
    logical_volume 'data1' do
      size '85%VG'
      filesystem 'ext4'
      # rightscale uses '/mnt/ephemeral'
      mount_point :location => '/mnt/ephemeral', :options => 'noatime,nodiratime'
      stripes devs.count
    end
  end

  bash "mount_lvm_ephemeral" do
    code <<-EOH
      mount -t ext4 -O rw,noatime,nodiratime /dev/mapper/vg0-data1 /mnt/ephemeral
    EOH
    user "root"
    cwd "/tmp"
    not_if "df | grep vg0-data1"
  end

end

