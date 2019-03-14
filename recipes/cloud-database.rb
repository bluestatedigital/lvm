# Cookbook Name:: bsd_lvm
# Recipe:: cloud-generic

include_recipe "bsd_lvm::default"

ephemeral_drives = []

if node[:ec2]
  # This is the maximum number of ephemeral drives any instance can allocate.
  max_ephemeral_count = 4

  # Try and gather all of the assigned ephemeral drives.
  max_ephemeral_count.times do |i|
    s = "block_device_mapping_ephemeral#{i}".to_sym
    if node[:ec2][s]
      ephemeral_drives << "/dev/#{node[:ec2][s]}"
    end
  end

  if !ephemeral_drives.empty?
    first_ed = ephemeral_drives[0]
    first_ed_code = first_ed.gsub(/\/dev\//, '')

    # Unmount the auto-mounted ephemeral drive.  Seems to be the first one, for whatever reason.
    mount first_ed do
      device first_ed
      action [:umount, :disable]
    end

    # We also try to unmount it manually because Chef doesn't like to do it via the mount resource
    # depending on the orientation of the moon, or the mood Mitt Romney was in when he woke up this morning.
    bash "unmount_default_ephemeral" do
      code <<-EOH
        umount /media/ephemeral0
      EOH
      user "root"
      cwd "/tmp"
      only_if "df | grep /media/ephemeral0"
    end
  end
end

# Now assemble our VG/LV if we found any ephemeral drives.
if !ephemeral_drives.empty?
  # Now create our volume group based on all the ephemeral drives present.
  bsd_lvm_volume_group 'vg0' do
    physical_volumes ephemeral_drives
    logical_volume 'data1' do
      size '85%VG'
      filesystem 'ext4'
      mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
      stripes ephemeral_drives.length
    end
  end
end
