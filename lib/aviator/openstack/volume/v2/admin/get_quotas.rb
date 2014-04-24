module Aviator

  define_request :get_quotas, inherit: [:openstack, :common, :v2, :admin, :base] do

    meta :service,      :volume
    meta :api_version,  :v2

    link 'documentation',
      'http://docs.openstack.org/trunk/openstack-ops/content/projects_users.html'
    link 'documentation',
      'https://github.com/openstack/python-cinderclient/blob/master/cinderclient/v2/quotas.py'

    param :tenant_id, required: true
    param :usage,     required: false


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      service_spec = session_data[:catalog].find{|s| s[:type] == 'volumev2' }
      v2_url = service_spec[:endpoints][0][:adminURL]
      str ="#{ v2_url }/os-quota-sets/#{ params[:tenant_id] }"
      str += "?usage=True" if params[:usage]

      str
    end

  end

end
