class Bid < ActiveRecord::Base
  belongs_to :req
  belongs_to :person
  validates_presence_of :estimated_hours, :person_id
  
  # attr_readonly :estimated_hours
  # so bids can be updated by a person

  attr_protected :person_id, :status_id, :created_at, :updated_at

  INACTIVE = 1
  OFFERED = 2
  ACCEPTED = 3
  COMMITTED = 4
  COMPLETED = 5
  SATISFIED = 6
  NOT_SATISFIED = 7
  
  def accepted?
    status_id >= ACCEPTED
  end 
   
  def alreadyaccepted?
    status_id > ACCEPTED
  end

  def approved?
    status_id == SATISFIED
  end

  def completed?
    completed_at != nil
  end

  def commitment?
    committed_at != nil
  end
  
  def confirmed?
    status_id > COMPLETED
  end
  
  def notaccepted?
    status_id < ACCEPTED
  end
  
  def notcompleted?
    status_id < COMPLETED
  end
  
  def notconfirmed?
    status_id < SATISFIED
  end
  
  def rated?
    approval != nil
  end
  
  def notrated?
    approval == nil
  end
  
  def thumbsup?
    approval == true
  end
  
  def thumbsdown?
    approval == false
  end

end
