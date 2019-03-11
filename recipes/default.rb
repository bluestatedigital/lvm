#
# Cookbook Name:: lvm
# Recipe:: default
#
# Copyright 2009-2013, Opscode, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package "lvm2"

chef_gem 'di-ruby-lvm'

gem_attribute_dir = "/opt/chef/embedded/lib/ruby/gems/1.9.1/gems/di-ruby-lvm-attrib-0.0.27/lib/lvm/attributes"
gem_attribute_ver = "2.02.180(2)"

remote_directory "#{gem_attribute_dir}/#{gem_attribute_ver}" do
    action :create_if_missing
    source "#{gem_attribute_ver}"
    only_if { ::File.directory?(gem_attribute_dir) }
end
