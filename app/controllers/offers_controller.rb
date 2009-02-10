class OffersController < ReqsController
  
  # over-ride the index method to find offers
  #
  def index
    @reqs = Req.find(:all, :conditions => "active = 1 AND isoffer = true", :order => 'created_at DESC')
                                                     # find offers, not Requests

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @reqs }
    end    
  end


end

