require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
    class CouchbaseCluster < Resource
      include Couchbase::CredentialsAttributes


      def initialize(*)
        super
        @action = :create_if_missing
        @allowed_actions.push :create_if_missing
        @resource_name = :couchbase_cluster

        self.class.attribute :cluster, :kind_of => String, :name_attribute => true
        self.class.attribute :exists, :kind_of => [TrueClass, FalseClass], :required => true
        self.class.attribute :memory_quota_mb, :kind_of => Integer, :required => true, :callbacks => {
        "must be at least 256" => lambda { |quota| quota >= 256 }
      }

      end

	# Define an attribute on this resource, including optional validation
	# parameters.
        def self.attribute(attr_name, validation_opts={})
            # Ruby 1.8 doesn't support default arguments to blocks, but we have to
            # use define_method with a block to capture +validation_opts+.
            # Workaround this by defining two methods :(
            class_eval(<<-SHIM, __FILE__, __LINE__)
                def #{attr_name}(arg=nil)
                    _set_or_return_#{attr_name}(arg)
                end
            SHIM

            define_method("_set_or_return_#{attr_name.to_s}".to_sym) do |arg|
                set_or_return(attr_name.to_sym, arg, validation_opts)
            end
        end
    end
  end
end
