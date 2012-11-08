class CustomersController < ApplicationController
  
 def index
    @customers = OTRS::Customer.where(:Search=>'*')
    p "ultimetly i get customers"
    p @customers
    respond_to do |wants|
      wants.html # index.html.erb
      wants.xml  { render :xml => @customers }
      wants.json { render :json => @customers }
    end
 end
  
  def create
     
  #  @cust = OTRS::Customer.new(params[:ticket])
  
     OTRS::Customer.fetchandimportfromopenerp

  #  respond_to do |wants|
  #    if @cust.save
  #      flash[:notice] = 'Ticket was successfully created.'
  #      wants.html { redirect_to(@ticket) }
  #      wants.xml  { render :xml => @ticket, :status => :created, :location => @ticket }
  #      wants.json { render :json => @ticket, :status => :created, :location => @ticket }
  #    else
  #      wants.html { render :action => "new" }
  #      wants.xml  { render :xml => @ticket.errors, :status => :unprocessable_entity }
  #      wants.json { render :json => @ticket.errors.full_messages, :status => :unprocessable_entity }
  #    end
  #  end
  render :text=>"import complete"
  end
  
  
end
