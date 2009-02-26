class HomeController < ApplicationController
  before_filter :setup
  skip_before_filter :require_activation
  
  def index
    
      if logged_in?
        redirect_to person_path(current_person)
      else
        redirect_to login_path
      end
    
    # @body = "home"
    # @topics = Topic.find_recent
    # @members = Person.find_recent
    # if logged_in?
    #   @feed = current_person.feed
    #   @some_contacts = current_person.some_contacts
    #   @requested_contacts = current_person.requested_contacts
    # else
    #   @feed = Activity.global_feed
    # end    
    # respond_to do |format|
    #   format.html
    # end  
    
  end
  
  def dashboard
  end
  
  
  private
  
    def setup
      @body = "home"
    end
    
    
end
