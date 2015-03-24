require 'test_helper'

class Aviator::Test

  describe 'aviator/openstack/compute/v2/public/list_flavors' do

    def create_request(session_data = get_session_data)
      klass.new(session_data)
    end


    def session
      unless @session
        @session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_member'
                   )
        @session.authenticate
      end

      @session
    end


    def admin_session
      unless @admin_session
        @admin_session = Aviator::Session.new(
                     config_file: Environment.path,
                     environment: 'openstack_admin'
                   )
        @admin_session.authenticate
      end

      @admin_session
    end


    def get_session_data
      session.send :auth_info
    end


    def helper
      Aviator::Test::RequestHelper
    end


    def klass
      @klass ||= helper.load_request('openstack', 'compute', 'v2', 'public', 'list_flavors.rb')
    end

    def create_private_flavor
      response = admin_session.compute_service.request :create_flavor do |params|
        params[:disk] = '1'
        params[:ram] = '1'
        params[:vcpus] = '1'
        params[:name] = 'testflavor'
        params[:'os-flavor-access:is_public'] = false
      end
      response.body[:flavor]
    end


    validate_attr :anonymous? do
      klass.anonymous?.must_equal false
    end


    validate_attr :api_version do
      klass.api_version.must_equal :v2
    end


    validate_attr :body do
      klass.body?.must_equal false
      create_request.body?.must_equal false
    end


    validate_attr :endpoint_type do
      klass.endpoint_type.must_equal :public
    end


    validate_attr :headers do
      headers = { 'X-Auth-Token' => get_session_data.token }

      request = create_request(get_session_data)

      request.headers.must_equal headers
    end


    validate_attr :http_method do
      create_request.http_method.must_equal :get
    end


    validate_attr :optional_params do
      klass.optional_params.must_equal [
        :details,
        :minDisk,
        :minRam,
        :marker,
        :limit,
        :show_private
      ]
    end


    validate_attr :required_params do
      klass.required_params.must_equal []
    end


    validate_attr :url do
      service_spec = get_session_data[:catalog].find{|s| s[:type] == 'compute' }
      url          = "#{ service_spec[:endpoints].find{|e| e[:interface] == 'public'}[:url] }/flavors"

      params = [
        [ :details, true                              ],
        [ :minDisk, 2                                 ],
        [ :minRam,  'cirros-0.3.1-x86_64-uec-ramdisk' ],
        [ :marker,  '123456'                          ],
        [ :limit,   10                                ]
      ]

      url += "/detail" if params.find{|pair| pair[0] == :details && pair[1] == true }

      filters = []

      params.select{|pair| pair[0]!=:details }.each{ |pair| filters << "#{ pair[0] }=#{ pair[1] }" }

      url += "?#{ filters.join('&') }" unless filters.empty?

      request = klass.new(get_session_data) do |p|
        params.each { |pair| p[pair[0]] = pair[1] }
      end

      request.url.must_equal url
    end


    validate_attr :param_aliases do
      aliases = {
        min_disk: :minDisk,
        min_ram:  :minRam
      }

      klass.param_aliases.must_equal aliases
    end


    validate_response 'no parameters are provided' do
      response = session.compute_service.request :list_flavors

      response.status.must_equal 200
      response.body.wont_be_nil
      response.headers.wont_be_nil
    end


    validate_response 'the details filter is provided' do
      response = session.compute_service.request :list_flavors do |params|
        params[:details] = true
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavors].length.wont_equal 0
      response.headers.wont_be_nil
    end


    validate_response 'the minDisk filter is provided' do
      response = session.compute_service.request :list_flavors do |params|
        params[:details] = true
      end

      max_disk_size = response.body[:flavors].max{|a,b| a[:disk] <=> b[:disk] }[:disk]
      total_entries = response.body[:flavors].count{|flv| flv[:disk] == max_disk_size }

      response = session.compute_service.request :list_flavors do |params|
        params[:minDisk] = max_disk_size
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      response.body[:flavors].length.must_equal total_entries
      response.headers.wont_be_nil
    end

    validate_response 'the show_private is provided' do
      flavor = create_private_flavor
      flavor_id = flavor[:id]
      response = admin_session.compute_service.request :list_flavors do |p|
        p[:details] = true
        p[:show_private] = true
      end

      created_private_flavor = response.body[:flavors].detect do |f|
        f[:id] == flavor_id
      end

      response.status.must_equal 200
      response.body.wont_be_nil
      created_private_flavor.wont_be_nil
    end

  end

end
