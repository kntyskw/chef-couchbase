require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
  class LWRPBase
    class CouchbaseSettings < LWRPBase
      include Couchbase::CredentialsAttributes

      attribute :group, :kind_of => String, :name_attribute => true
      attribute :settings, :kind_of => Hash, :required => true

      def initialize(*)
        super
        @action = :modify
        @allowed_actions.push :modify
	if Chef::VERSION < '11'
        	@resource_name = :couchbase_settings
	else
        	@resource_name = "CouchbaseSettings"
	end
      end
    end
  end
  end
end
