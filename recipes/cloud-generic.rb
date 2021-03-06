# Cookbook Name:: bsd_lvm
# Recipe:: ec2-db-ephemeral

include_recipe "bsd_lvm::default"

if(node[:ec2])
  if(node[:ec2][:instance_type] == 'm1.xlarge' || node[:ec2][:instance_type] == 'cc2.8xlarge')
    #
    # Unmount the Auto-mounted ephemerial drive
    # Chef's mount resource seems to balk at this, so we're scripting it
    #

    # First device comes mounted
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

    # First device comes mounted
    bsd_lvm_volume_group 'vg0' do
      physical_volumes [ '/dev/xvdb', '/dev/xvdc', '/dev/xvdd', '/dev/xvde' ]
      logical_volume 'data1' do
        size '85%VG'
        filesystem 'ext4'
        mount_point :location => '/media/ephemeral0', :options => 'noatime,nodiratime'
        stripes 4
      end
    end
  end
end
