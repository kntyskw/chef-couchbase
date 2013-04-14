require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
    class CouchbaseNode < Resource
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

      attribute :retries, :kind_of => Integer, :default => 3
      attribute :id, :kind_of => [ String ], :name_attribute => true
      attribute :database_path, :kind_of => String, :default => "/opt/couchbase/var/lib/couchbase/data"

      def initialize(*)
        super
        @action = :modify
        @allowed_actions.push(:modify)
        @resource_name = :couchbase_node
      end
    end
  end
end
