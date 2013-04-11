require "chef/resource"
require File.join(File.dirname(__FILE__), "credentials_attributes")

class Chef
  class Resource
    class CouchbaseBucket < Resource
      include Couchbase::CredentialsAttributes
      def initialize(*)
        super
        @action = :create
        @allowed_actions.push :create
	@resource_name = :couchbase_bucket

        self.class.attribute :bucket, :kind_of => String, :name_attribute => true
        self.class.attribute :cluster, :kind_of => String, :default => "default"
        self.class.attribute :exists, :kind_of => [TrueClass, FalseClass], :required => true

        self.class.attribute :memory_quota_mb, :kind_of => Integer, :callbacks => {
          "must be at least 100" => lambda { |quota| quota >= 100 },
        }

        self.class.attribute :memory_quota_percent, :kind_of => Numeric, :callbacks => {
          "must be a positive number" => lambda { |percent| percent > 0.0 },
          "must be less than or equal to 1.0" => lambda { |percent| percent <= 1.0 },
        }

        self.class.attribute :replicas, :kind_of => [Integer, FalseClass], :default => 1, :callbacks => {
          "must be a non-negative integer" => lambda { |replicas| !replicas || replicas > -1 },
        }

        self.class.attribute :type, :kind_of => String, :default => "couchbase", :callbacks => {
           "must be either couchbase or memcached" => lambda { |type| %w(couchbase memcached).include? type },
         }

      end
      def self.attribute(attr_name, validation_opts={})
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
