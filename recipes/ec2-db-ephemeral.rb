include_recipe "lvm::default"

if(node[:ec2][:instance_type] =~ /(cc2\.8|m1\.)xlarge/)
  #
  # Unmount the Auto-mounted ephemerial drive
  # Chef's mount resource seems to balk at this, so we're scripting it
  #
  if(node[:platform] == 'centos')
    mount "/dev/xvdb" do
      device "/dev/xvdb"
      action [:umount, :disable]
    end

    bash "unmount_default_ephemeral" do
      code <<-EOH
        umount /mnt/ephemeral
      EOH
      user "root"
      cwd "/tmp"
      only_if "df | grep xvdb"
    end
  end

  if(node[:platform] == 'amazon')
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
      only_if "df | grep sdb"
    end
  end

  lvm_volume_group 'vg0' do
    physical_volumes [ '/dev/xvdb', '/dev/xvdc', '/dev/xvdd', '/dev/xvde' ]
    logical_volume 'data1' do
      size '75%VG'
      filesystem 'ext4'
      mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
      stripes 4
    end
  end
end
