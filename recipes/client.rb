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

if platform_family?('rhel')
	package_machine = node['kernel']['machine'] == "i386" ? "i386" : "x86_64"
	yum_repository "couchbase" do
		description "Couchbase yum repository"
		url node['couchbase']['repository']['yum']['centos6'][package_machine]
		mirrorlist true
		enabled 1
	end

	yum_package "libcouchbase2" 
	yum_package "libcouchbase-devel" 
	yum_package "libvbucket"
		
elsif platform_family?('debian')
	if platform?('ubuntu')
		version = node['platform_version']
		apt_repository "couchbase" do
			description "Couchbase apt repository"
			url node['couchbase']['repository']['apt']['ubuntu'][version]
		end
	end

	apt_package "libcouchbase2" 
	apt_package "libcouchbase-devel" 
	apt_package "libvbucket"
end

