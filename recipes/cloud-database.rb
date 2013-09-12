# Cookbook Name:: lvm
# Recipe:: cloud-generic

include_recipe "lvm::default"

if node[:ec2]
  # This is the maximum number of ephemeral drives any instance can allocate.
  max_ephemeral_count = 4
  ephemeral_drives = []

  # Try and gather all of the assigned ephemeral drives.
  max_ephemeral_count.times do |i|
    s = "block_device_mapping_ephemeral#{i}".to_sym
    if node[:ec2][s]
      ephemeral_drives << "/dev/#{node[:ec2][s]}"
    end
  end

  if !ephemeral_drives.empty?
    # Unmount the auto-mounted ephemeral drive.  Seems to be the first one, for whatever reason.
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

    # Now create our volume group based on all the ephemeral drives present.
    lvm_volume_group 'vg0' do
      physical_volumes ephemeral_drives
      logical_volume 'data1' do
        size '85%VG'
        filesystem 'ext4'
        mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
        stripes ephemeral_drives.length
      end
    end
  end
end

