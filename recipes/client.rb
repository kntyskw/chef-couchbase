#
# Cookbook Name:: couchbase
# Recipe:: client
#
# Copyright 2013, kntyskw
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
case node['platform']
  when 'centos','redhat','fedora','amazon', 'scientific'
    platform_family = 'rhel'
  when 'debian', 'ubuntu'
    platform_family = 'debian'
end

if platform_family == 'rhel'
	execute 'reload-external-yum-cache' do
	 command 'yum makecache'
	 action :nothing
	end
	 
	ruby_block "reload-internal-yum-cache" do
		block do
		  Chef::Provider::Package::Yum::YumCache.instance.reload
		end
		action :nothing
	end
	 
	package_machine = node['kernel']['machine'] == "i386" ? "i386" : "x86_64"

	remote_file '/etc/yum.repos.d/foo.repo' do
		source node['couchbase']['repository']['yum']['centos6'][package_machine]
		mode '00644'
		action :create_if_missing
		notifies :run, resources(:execute => 'reload-external-yum-cache'), :immediately
		notifies :create, resources(:ruby_block => 'reload-internal-yum-cache'), :immediately
	end

	yum_package "libevent" 
	yum_package "libcouchbase2" 
	yum_package "libcouchbase-devel" 
	yum_package "libvbucket1"
		
elsif platform_family == 'debian'
	if platform?('ubuntu')
		codename = node['lsb']['codename']
		apt_repository "couchbase" do
			uri "http://packages.couchbase.com/ubuntu"
			distribution codename
			components [codename, "#{codename}/main"]
			key "http://packages.couchbase.com/ubuntu/couchbase.key"
		end
	end

	apt_package "libcouchbase2" 
	apt_package "libcouchbase-dev" 
end

