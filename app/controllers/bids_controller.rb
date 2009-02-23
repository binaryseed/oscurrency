class BidsController < ApplicationController
  before_filter :login_required, :only => [:new,:edit,:create,:update,:destroy]
  before_filter :setup
  
  skip_before_filter :setup, :only => [:edit]

  # POST /bids
  # POST /bids.xml
  def create
    #@bid = Bid.new(params[:bid])
    @bid = @req.bids.new(params[:bid])
    @bid.person = current_person
    @bid.status_id = Bid::OFFERED
    if @bid.expiration_date.blank?
      @bid.expiration_date = 7.days.from_now
    else
      @bid.expiration_date += 1.day - 1.second # make expiration date at end of day
    end

    respond_to do |format|
      if @bid.save
        bid_note = Message.new()
        bid_note.subject = "BID: " + @bid.estimated_hours.to_s + " marbles - " + @req.name 
        bid_note.content = "See your <a href=\"" + req_path(@req) + "\">request</a> to consider bid"
        bid_note.sender = @bid.person
        bid_note.recipient = @req.person
        bid_note.save!

        flash[:notice] = 'Bid was successfully created.'
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid, :status => :created, :location => @bid }
      else
        flash[:error] = 'Error creating bid.'
        format.html { redirect_to req_path(@req) }
        #format.xml  { render :xml => @bid.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  # GET /bids/1/edit
  def edit
    @bid = Bid.find(params[:id])
    @req = @bid.req
  end

  # PUT /bids/1
  # PUT /bids/1.xml
  def update
    @bid = Bid.find(params[:id])

    updated_bid = params[:bid]
    
    # take care of the update that comes from bid/id/edit, or from thumbs up/down 
    if params[:content_update]
      if @bid.update_attributes!(params[:bid])
        flash[:success] = 'Bid successfully updated.'
      else
        flash[:error] = 'Error when updating bid.'
      end
      redirect_to(@req)
      return
    end
    
    status = updated_bid[:status_id]

    case @bid.status_id
    when Bid::OFFERED
      unless current_person?(@req.person)
        flash[:error] = 'Nothing to see here. Move along'
      else
        if Bid::ACCEPTED != status.to_i
          flash[:error] = 'Unexpected state change'
          logger.warn "Error. Bad state change: #{status}. expecting ACCEPTED"
          redirect_to(@req)
          return
        end
        @bid.accepted_at = Time.now
        @bid.status_id = Bid::ACCEPTED
        if @bid.save!
          flash[:notice] = 'Bid accepted. Message sent to bidder to commit'
          bid_note = Message.new()
          bid_note.subject = "BID: accepted - " + @req.name # XXX make sure length does not exceed 40 chars
          bid_note.content = "See the <a href=\"" + req_path(@req) + "\">request</a> to commit to bid"
          bid_note.sender = @req.person
          bid_note.recipient = @bid.person
          bid_note.save!
          redirect_to(@req)
        else
          # XXX bid not saved
          redirect_to(@req)
        end
      end
    when Bid::ACCEPTED
      unless current_person?(@bid.person)    or current_person?(@req.person)
        if current_person?(@req.person)      or current_person?(@bid.person)
          # check for approval
          if Bid::SATISFIED != status.to_i
            flash[:error] = 'Unexpected state change'
            logger.warn "Error. Bad state change: #{status}. expecting satisfied"
            redirect_to(@req)
            return
          end
          process_approval
          redirect_to(@req)
        else
          flash[:error] = 'Nothing to see here. Move along'
        end
      else
        if Bid::COMMITTED != status.to_i
          flash[:error] = 'Unexpected state change'
          logger.warn "Error. Bad state change: #{status}. expecting COMMITTED"
          redirect_to(@req)
          return
        end
        @bid.committed_at = Time.now
        @bid.status_id = Bid::COMMITTED
        if @bid.save!
          flash[:notice] = 'Bid committed. Notification sent to requestor'
          bid_note = Message.new()
          bid_note.subject = "BID: committment - " + @req.name # XXX make sure length does not exceed 40 chars
          bid_note.content = "Commitment made for your <a href=\"" + req_path(@req) + "\">request</a>. This is an automated message"
          bid_note.sender = @bid.person
          bid_note.recipient = @req.person
          bid_note.save!
          redirect_to(@req)
        else
          # XXX bid not saved
          redirect_to(@req)
        end
      end
    when Bid::COMMITTED
      unless current_person?(@bid.person)       or current_person?(@req.person)
        if current_person?(@req.person)         or current_person?(@bid.person)
          # check for approval
          if Bid::SATISFIED != status.to_i
            flash[:error] = 'Unexpected state change expecting satisfied'
            logger.warn "Error. Bad state change: #{status}. expecting satisfied"
            redirect_to(@req)
            return
          end
          process_approval
          redirect_to(@req)
        else
          flash[:error] = 'Nothing to see here. Move along'
        end
      else
        
        # OK to skip directely to "confirm complete"
        if Bid::SATISFIED == status.to_i
          process_approval
          redirect_to(@req)
          return
        end
        
        if Bid::COMPLETED != status.to_i
          flash[:error] = 'Unexpected state change expecting COMPLETED'
          logger.warn "Error. Bad state change: #{status}. expecting COMPLETED"
          redirect_to(@req)
          return
        end
        @bid.completed_at = Time.now
        @bid.status_id = Bid::COMPLETED
        if @bid.save!
          flash[:notice] = 'Work marked completed. Notification sent to requestor'
          bid_note = Message.new()
          bid_note.subject = "BID: Work completed - " + @req.name # XXX make sure length does not exceed 40 chars
          bid_note.content = "Work completed for your <a href=\"" + req_path(@req) + "\">request</a>. Please approve transaction! This is an automated message"
          bid_note.sender = @bid.person
          bid_note.recipient = @req.person
          bid_note.save!
          redirect_to(@req)
        else
          # XXX bid not saved
          redirect_to(@req)
        end
      end
    when Bid::COMPLETED
      unless current_person?(@req.person)       or current_person?(@bid.person)
        flash[:error] = 'Nothing to see here. Move along'
      else
        if Bid::SATISFIED != status.to_i
          flash[:error] = 'Unexpected state change'
          logger.warn "Error. Bad state change: #{status}. expecting satisfied"
          redirect_to(@req)
          return
        end
        process_approval
        redirect_to(@req)
      end
    else
      logger.warn "Error.  Unexpected bid status: #{@bid.status_id}"
    end

  end

  # DELETE /bids/1
  # DELETE /bids/1.xml
  def destroy
    @bid = Bid.find(params[:id])
    @bid.destroy

    respond_to do |format|
      flash[:success] = 'Bid was removed.'
      format.html { redirect_to req_url(@req) }
      #format.xml  { head :ok }
    end
  end

  private

  def setup
    @req = Req.find(params[:req_id])
    @body = "req"
  end

  def process_approval
    @bid.approved_at = Time.now
    @bid.status_id = Bid::SATISFIED
    
    if @req.offer?
      Account.transfer(@bid.person.account,@req.person.account,@bid.estimated_hours,@req)
    else
      Account.transfer(@req.person.account,@bid.person.account,@bid.estimated_hours,@req)
    end

    if @bid.save!
      flash[:notice] = 'Work marked verified. Approval notification sent'
      bid_note = Message.new()
      bid_note.subject = "BID: Verified - " + @req.name + " (#{@bid.estimated_hours} marbles earned)" # XXX make sure length does not exceed 40 chars
      if @req.offer?
        bid_note.content = "#{@bid.person.name} has verified your work for <a href=\"" + req_path(@req) + "\">#{@bid.person.name}</a>. This is an automated message"
        bid_note.sender = @bid.person
        bid_note.recipient = @req.person
      else
        bid_note.content = "#{@req.person.name} has verified your work for <a href=\"" + req_path(@req) + "\">#{@req.name}</a>. This is an automated message"
        bid_note.sender = @req.person
        bid_note.recipient = @bid.person
      end
      bid_note.save!
    else
      # XXX handle error
    end
  end
end
