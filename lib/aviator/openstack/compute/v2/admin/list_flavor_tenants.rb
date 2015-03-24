module Aviator

  define_request :list_flavor_tenants, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service, :compute

    link 'documentation',
         'http://developer.openstack.org/api-ref-compute-v2-ext.html#ext-os-flavor-access'

    param :flavor_id, required: true


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      str  = "#{ base_url }/flavors"
      str += "/#{ params[:flavor_id] }"
      str += "/os-flavor-access"
      str
    end

  end

end
