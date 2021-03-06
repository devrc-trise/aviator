module Aviator

  define_request :list_users do

    meta :provider,      :openstack
    meta :service,       :identity
    meta :api_version,   :v2
    meta :endpoint_type, :admin

    link 'documentation',
      'http://docs.openstack.org/api/openstack-identity-service/2.0/content/GET_listUsers_v2.0_users_.html'


    def headers
      h = {}

      unless self.anonymous?
        h['X-Auth-Token'] = session_data.token
      end

      h
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:catalog].find{|s| s[:type] == 'identity' }
      "#{ service_spec[:endpoints].find{|e| e[:interface] == 'admin'}[:url] }/users"
    end

  end

end
