include_recipe "lvm::default"
if(node[:ec2][:instance_type] == 'm1.xlarge')
  # First device comes mounted
  mount "/dev/sdb" do
    device "/dev/sdb"
    action :umount
  end
  lvm_volume_group 'vg00' do
    physical_volumes [ '/dev/sdb', '/dev/sdc', '/dev/sdd', '/dev/sde' ]
    logical_volume 'data1' do
      size '75%VG'
      filesystem 'ext4'
      mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
      stripes 4
    end
  end
end
