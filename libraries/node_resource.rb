require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
  class LWRPBase
    class CouchbaseNode < LWRPBase
      include Couchbase::CredentialsAttributes

      attribute :id, :kind_of => String, :name_attribute => true
      attribute :database_path, :kind_of => String, :default => "/opt/couchbase/var/lib/couchbase/data"

      def initialize(*)
        super
        @action = :modify
        @allowed_actions.push(:modify)
        if Chef::VERSION < '11'
        	@resource_name = :couchbase_node
	else
        	@resource_name = "CouchbaseNode"
	end
      end
    end
  end
  end
end
