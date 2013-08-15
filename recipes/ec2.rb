include_recipe "lvm::default"
if(node[:ec2][:instance_type] == 'm1.xlarge')
  #
  # Unmount the Auto-mounted ephemerial drive
  # Chef's mount resource seems to balk at this, so we're scripting it
  #
   
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
    not_if "lvs| grep data1"
  end
  # First device comes mounted
  lvm_volume_group 'vg00' do
    physical_volumes [ '/dev/xvdb', '/dev/xvdc', '/dev/xvdd', '/dev/xvde' ]
    logical_volume 'data1' do
      size '75%VG'
      filesystem 'ext4'
      mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
      stripes 4
    end
  end
end
