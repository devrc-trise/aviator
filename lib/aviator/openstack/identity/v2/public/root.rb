module Aviator

  define_request :root, inherit: [:openstack, :common, :v2, :public, :base] do

    meta :service, :identity


    def headers
      super
    end


    def http_method
      :get
    end


    def url
      uri = URI(base_url)
      "#{ uri.scheme }://#{ uri.host }:#{ uri.port.to_s }/v2.0/"
    end

  end

end
