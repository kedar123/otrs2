class OTRS
  include ActiveModel::Conversion
  include ActiveModel::Naming
  include ActiveModel::Validations

  
  # @@otrs_host is the address where the OTRS server presides
  @@otrs_host = '192.168.1.20'
  # api_url is the base URL used to connect to the json api of OTRS, this will be the custom json.pl as the standard 
  # doesn't include ITSM module
  @@otrs_api_url = "https://#{@@otrs_host}/otrs/json.pl"
  # Username / password combo should be an actual OTRS agent defined on the OTRS server
  # I have not tested this with other forms of OTRS authentication
  @@otrs_user = 'root@localhost'
  @@otrs_pass = 'root'
  
  def self.user
    @@otrs_user
  end
  
  def self.password
    @@otrs_pass
  end
  
  def self.host
    @@otrs_host
  end
  
  def self.api_url
    @@otrs_api_url
  end
  
  def self.connect(params)
    require 'net/https'
    base_url = self.api_url
    Rails.logger.info "base urllll"
    Rails.logger.info base_url.inspect
    Rails.logger.info "user"
    Rails.logger.info self.user
    Rails.logger.info "password"
    Rails.logger.info self.password
    
    
    logon = URI.encode("User=#{self.user}&Password=#{self.password}")
    
    Rails.logger.info "logonnn"
    Rails.logger.info logon.inspect
    Rails.logger.info "params[:object]"
    Rails.logger.info params[:object].inspect
    
    object = URI.encode(params[:object])
    Rails.logger.info "object"
    Rails.logger.info object.inspect
    
    method = URI.encode(params[:method])
    Rails.logger.info "method"
    Rails.logger.info method.inspect
    
    Rails.logger.info "params[:data]"
    Rails.logger.info params[:data].inspect
    
    data = params[:data].to_json
    Rails.logger.info "data"
    Rails.logger.info data.inspect
    
    data = URI.encode(data)
    Rails.logger.info "data"
    Rails.logger.info data.inspect
    
    data = URI.escape(data, '=\',\\/+-&?#.;')
    Rails.logger.info "data"
    Rails.logger.info data.inspect
    
    uri = URI.parse("#{base_url}?#{logon}&Object=#{object}&Method=#{method}&Data=#{data}")
    Rails.logger.info "the url for creation"
    Rails.logger.info uri.inspect
     
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    request = Net::HTTP::Get.new(uri.request_uri)
    response = http.request(request)
    result = ActiveSupport::JSON::decode(response.body)
    if result["Result"] == 'successful'
      result["Data"]
    else
      raise "Error:#{result["Result"]} #{result["Data"]}"
    end
  end
  
  def connect(params)
    self.class.connect(params)
  end
end
