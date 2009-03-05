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

  # POST /offers
  # POST /offers.xml
  def create
    @req = Req.new(params[:req])

    if @req.due_date == nil
      @req.due_date = Time.now + 1.month
    end
    
    @req.due_date += 1.day - 1.second # make due date at end of day
    @req.person_id = current_person.id
    @req.isoffer = true

    respond_to do |format|
      if @req.save
        flash[:success] = "Offer was successfully created. <script type='text/javascript'>fb_offer()</script> "
        format.html { redirect_to(@req) }
        format.xml  { render :xml => @req, :status => :created, :location => @req }
      else
        @all_categories = Category.find(:all, :order => "parent_id, name").sort_by { |a| a.long_name }
        format.html { render :action => "new" }
        format.xml  { render :xml => @req.errors, :status => :unprocessable_entity }
      end
    end
  end


end

