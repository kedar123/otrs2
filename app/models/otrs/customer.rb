class OTRS::Customer < OTRS
  # Validations aren't working
  attr_accessor :email, :login, :customer_id, :first_name,:last_name,:UserFirstname,:UserLastname,:UserCustomerID,:UserLogin,:UserPassword,:UserEmail,:UserCustomerID,:ValidID,:UserID
  validates_presence_of :email
  validates_presence_of :login
  #validates_presence_of :customer_id
  validates_presence_of :first_name
  validates_presence_of :last_name
  

  def self.set_accessor(key)
    attr_accessor key.to_sym
  end
  
  def persisted?
    false
  end
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      OTRS::Customer.set_accessor(name.to_s.underscore)
      send("#{name.to_s.underscore.to_sym}=", value)
    end
  end
  
   
  def attributes
    attributes = {}
    self.instance_variables.each do |v|
      attributes[v.to_s.gsub('@','').to_sym] = self.instance_variable_get(v)
    end
    attributes
  end
  
  def save
    self.create(self.attributes)
  end
  
  def create(attributes)
     
    p "i am here in create method of customer" 
    #logger.info "customer creation"
    data = attributes
    params = { :object => 'CustomerUserObject', :method => 'CustomerUserAdd', :data => data }
    a = connect(params)
     
      
  end
  
   
  def self.fetchandimportfromopenerp
      @ooor = Ooor.new(:url => 'http://192.168.1.20:8069/xmlrpc', :database => 'otrs_db', :username =>'admin', :password   => 'admin')
     
      ResPartner.find(:all).each do |respart|  
      
      cust = OTRS::Customer.new()
      p "sssssssss"
      p respart.address[0]
      p respart.address[0].name
      p respart.name
      if respart.address[0].name
      cust.UserFirstname = respart.address[0].name.split(" ")[0]
      if respart.address[0].name.split(" ")[1].blank?
        cust.UserLastname = respart.address[0].name.split(" ")[0]
      else
        cust.UserLastname = respart.address[0].name.split(" ")[1]
      end
      #set Framework -> Core: CheckMXRecord = No
     p "wwwww"
      else
      cust.UserFirstname = respart.name.split(" ")[0]
      if respart.name.split(" ")[1].blank?
        cust.UserLastname = respart.name.split(" ")[0]
      else
        cust.UserLastname = respart.name.split(" ")[1]
      end
      
     p "aaaaaaa"
      end
      cust.UserCustomerID = respart.id
      cust.UserLogin = respart.name
      cust.UserPassword = respart.name
      cust.UserEmail = respart.email
      cust.ValidID = 1
      cust.UserID = respart.id
      cust.save
  end      
      
  end
   
  
   
  def self.where(attributes)
      @ooor = Ooor.new(:url => 'http://192.168.1.20:8069/xmlrpc', :database => 'otrs_db', :username =>'admin', :password   => 'admin')
    
    Rails.logger.info "from customer listttt"
    data = attributes
    params = { :object => 'CustomerUserObject', :method => 'CustomerSearch', :data => data }
    a = connect(params)
    b = Hash[*a]          # Converts array to hash where key = TicketID and value = TicketNumber, which is what gets returned by OTRS
    Rails.logger.info "but i got thisssssss"
    Rails.logger.info a.inspect
    c = []
    b.each do |key,value| # Get just the ID values so we can perform a find on them
      c << key
    end
    results = []
    c.each do |t|
      results << t  #Add find results to array
    end
    Rails.logger.info "changed into array"
    Rails.logger.info results.inspect
    
    
    results   # Return array of hashes.  Each hash is one ticket record
    #and the result is like this it will fetch all the array with user name and then need a loop on that and fetch all the 
    #records in detail with name
    results.each do |res|
      
       params = { :object => 'CustomerUserObject', :method => 'CustomerUserDataGet', :data => {:User=>res} }
       uda = connect(params)
       udha = Hash[*uda]
       Rails.logger.info udha.inspect
       Rails.logger.info  "inspect"
       
       Rails.logger.info udha[:UserMobile]
       
       #self.create_res_partner(udha)
       
    end
    
    
  end
  
  def self.create_res_partner(udha)
    old_res = ResPartner.search([["name","=",udha['UserLogin']]])[0] 
      if old_res.blank?
         respart = ResPartner.new 
         respart.name = udha['UserLogin']
         respart.active = true
         if !udha['UserTitle'].blank?
              oldrest = ResPartnerTitle.search([["shortcut","=",udha['UserTitle']]])[0]
           if oldrest.blank?
             newrest =  ResPartnerTitle.new
             newrest.shortcut = udha['UserTitle']
             newrest.name = udha['UserTitle']
             newrest.domain = "contact"
             newrest.save
             oldrest = newrest.id     
           end
          respart.title = oldrest 
         end
         respart.company_id = 1
         respart.customer = true
         respart.supplier = false
         respart.employee = false 
         respart.save
         respartadd = ResPartnerAddress.new
         respartadd.partner_id = respart.id 
         respartadd.type = 'invoice'
         respartadd.name = udha['UserLogin']
         respartadd.street = udha['UserStreet']
         respartadd.city = udha['UserCity']
         respartadd.zip = udha['UserZip']
         respartadd.active = true
         respartadd.title = oldrest
         respartadd.phone = udha['UserPhone']
         respartadd.mobile = udha['UserMobile']
         respartadd.email = udha['UserEmail']
         respartadd.save
      else
        Rails.logger.info  "this user is already there"
      end
  end
  
  
  
  
  def where(attributes)
    self.class.where(attributes)
  end
   
end