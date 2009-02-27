# == Schema Information
# Schema version: 20090223070356
#
# Table name: bids
#
#  id              :integer(4)      not null, primary key
#  req_id          :integer(4)      
#  person_id       :integer(4)      
#  status_id       :integer(4)      
#  estimated_hours :decimal(8, 2)   default(0.0)
#  actual_hours    :decimal(8, 2)   default(0.0)
#  expiration_date :datetime        
#  created_at      :datetime        
#  updated_at      :datetime        
#  accepted_at     :datetime        
#  committed_at    :datetime        
#  completed_at    :datetime        
#  approved_at     :datetime        
#  rejected_at     :datetime        
#  description     :text            
#  approval        :boolean(1)      
#  feedback        :text            
#

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
    # completed_at != nil
    status_id >= COMPLETED
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
