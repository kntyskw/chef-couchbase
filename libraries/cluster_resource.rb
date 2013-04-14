require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
    class CouchbaseCluster < Resource
      include Couchbase::CredentialsAttributes

      def self.method_missing(meth, *args, &block)
        if meth.to_s =~ /^attribute$/
          self.__attribute(args[0], args[1])
        else
          super
        end
      end

      def self.__attribute(attr_name, validation_opts={})
        class_eval(<<-SHIM, __FILE__, __LINE__)
                def #{attr_name}(arg=nil)
                _set_or_return_#{attr_name}(arg)
                end
        SHIM

        define_method("_set_or_return_#{attr_name.to_s}".to_sym) do |arg|
          set_or_return(attr_name.to_sym, arg, validation_opts)
        end
      end

      attribute :cluster, :kind_of => String, :name_attribute => true
      attribute :member_host_ip, :kind_of => String, :name_attribute => true
      attribute :member_port, :kind_of => Integer, :name_attribute => true
      attribute :my_ip, :kind_of => String, :name_attribute => true
      attribute :exists, :kind_of => [TrueClass, FalseClass], :required => true
      attribute :memory_quota_mb, :kind_of => Integer, :required => true, :callbacks => { "must be at least 256" => lambda { |quota| quota >= 256 } }

      def initialize(*)
        super
        @action = :create_if_missing
        @allowed_actions.push :create_if_missing 
	@allowed_actions.push :join_cluster_if_specified
        @resource_name = :couchbase_cluster

      end
    end
  end
end
