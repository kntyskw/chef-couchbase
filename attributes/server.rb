package_machine = node['kernel']['machine'] == "x86_64" ? "x86_64" : "x86"

# platform_family? is not available on old chef and opsworks
# if platform_family?('rhel')

case node['platform']
  when 'centos','redhat','fedora','amazon','scientific'
    packaging = "rpm"
  when 'debian','ubuntu'
    packaging = "deb"
end

default['couchbase']['server']['edition'] = "community"
default['couchbase']['server']['version'] = "2.0.0"

default['couchbase']['server']['package_file'] = "couchbase-server-#{node['couchbase']['server']['edition']}_#{package_machine}_#{node['couchbase']['server']['version']}.#{packaging}"
default['couchbase']['server']['package_base_url'] = "http://packages.couchbase.com/releases/#{node['couchbase']['server']['version']}"
default['couchbase']['server']['package_full_url'] = "#{node['couchbase']['server']['package_base_url']}/#{node['couchbase']['server']['package_file']}"

default['couchbase']['server']['database_path'] = "/opt/couchbase/var/lib/couchbase/data"
default['couchbase']['server']['log_dir'] = "/opt/couchbase/var/lib/couchbase/logs"

default['couchbase']['server']['username'] = ""
default['couchbase']['server']['password'] = ""

default['couchbase']['server']['memory_quota_mb'] = Couchbase::MaxMemoryQuotaCalculator.from_node(node).in_megabytes
default['couchbase']['default_bucket']['memory_quota_mb'] = 100

default['couchbase']['cluster']['member_host_ip'] = "127.0.0.1"
default['couchbase']['cluster']['member_port'] = 8091
