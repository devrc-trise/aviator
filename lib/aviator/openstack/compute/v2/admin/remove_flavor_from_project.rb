module Aviator

  define_request :remove_flavor_from_project, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-flavor-access'

    param :flavor_id,          required: true
    param :tenant,             required: true



    def headers
      super
    end

    def body
      p = {
        removeTenantAccess: {
          tenant: params[:tenant]
        }
      }
    end

    def http_method
      :delete
    end


    def url
      puts ">>>>>>>URL: #{ base_url }/flavors/#{ params[:flavor_id] }/action"
      puts ">>>>>>>BODY: #{ body.inspect }"
      "#{ base_url }/flavors/#{ params[:flavor_id] }/action"
    end

  end

end