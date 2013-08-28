# Cookbook Name:: lvm
# Recipe:: ec2-db-ephemeral

include_recipe "lvm::default"

devs = %w{
  /dev/sdb
  /dev/sdc
  /dev/sdd
  /dev/sde
  /dev/sdf
  /dev/sdg
}

mount "/dev/sdb" do
  device "/dev/sdb"
  action [:umount, :disable]
end

bash "unmount_default_ephemeral" do
  code <<-EOH
    umount /media/ephemeral0
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
    mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
    stripes 6
  end
end

