require "chef/provider"
require File.join(File.dirname(__FILE__), "client")
require File.join(File.dirname(__FILE__), "cluster_data")

class Chef
  class Provider
    class CouchbaseCluster < Provider
      include Couchbase::Client
      include Couchbase::ClusterData

      def load_current_resource
        @current_resource = Resource::CouchbaseCluster.new @new_resource.name
        @current_resource.cluster @new_resource.cluster
        @current_resource.exists !!pool_data
        @current_resource.memory_quota_mb pool_memory_quota_mb if @current_resource.exists
      end

      def action_create_if_missing
        unless is_cluster_member_host
          Chef::Log.info "Not the cluster member host. Will skip."
          return
        end
        unless @current_resource.exists
          post "/pools/#{@new_resource.cluster}", "memoryQuota" => @new_resource.memory_quota_mb
          @new_resource.updated_by_last_action true
          Chef::Log.info "#{@new_resource} created"
        end
      end

      def action_join_cluster_if_specified
        unless is_cluster_member_host
          response = post_no_error_check "/node/controller/doJoinCluster",
            "clusterMemberHostIp" => @new_resource.member_host_ip,
            "clusterMemberPort" => @new_resource.member_port,
            "user" => @new_resource.username,
            "password" => @new_resource.password
          unless response.kind_of? Net::HTTPSuccess
            unless response.body.include?("Node is already part of cluster")
              Chef::Log.error response.body
              return
            end
          end
          @new_resource.updated_by_last_action true
          Chef::Log.info "#{@new_resource} joined the existing cluster"
        else
          Chef::Log.info "I am the cluster member host. Will skip."
        end
      end

      def action_initiate_rebalance
        post "/controller/rebalance",
          "ejectedNodes" => "",
          "knownNodes" => get_node_opt_names_in_cluster.join(","),
          "user" => @new_resource.username,
          "password" => @new_resource.password
        Chef::Log.info "rebalance for #{@new_resource} initiated"
      end

      def get_node_opt_names_in_cluster
        cluster = JSON.parse((get "/pools/default").body)
        node_opt_names = []
        for node in cluster['nodes']
          node_opt_names.push node['otpNode']
        end
        return node_opt_names
      end

      def is_cluster_member_host
        if @new_resource.member_host_ip == "localhost" ||
          @new_resource.member_host_ip == "127.0.0.1" ||
          @new_resource.member_host_ip == "::1" ||
          @new_resource.member_host_ip == @new_resource.my_ip
          return true
	      end
	      return false
      end
    end
  end
end
