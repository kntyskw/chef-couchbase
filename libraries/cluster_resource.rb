require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
  class LWRPBase
    #class CouchbaseCluster < Resource
    class CouchbaseCluster < LWRPBase
      include Couchbase::CredentialsAttributes

      attribute :cluster, :kind_of => String, :name_attribute => true
      attribute :exists, :kind_of => [TrueClass, FalseClass], :required => true
      attribute :memory_quota_mb, :kind_of => Integer, :required => true, :callbacks => {
        "must be at least 256" => lambda { |quota| quota >= 256 }
      }

      def initialize(*)
        super
        @action = :create_if_missing
        @allowed_actions.push :create_if_missing
	if Chef::VERSION < '11'
        	@resource_name = :couchbase_cluster
	else
        	@resource_name = "CouchbaseCluster"
	end
      end
    end
  end
  end
end
