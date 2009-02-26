# == Schema Information
# Schema version: 20090223070356
#
# Table name: exchanges
#
#  id          :integer(4)      not null, primary key
#  customer_id :integer(4)      
#  worker_id   :integer(4)      
#  req_id      :integer(4)      
#  amount      :decimal(8, 2)   default(0.0)
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Exchange < ActiveRecord::Base
  include ActivityLogger

  belongs_to :customer, :class_name => "Person", :foreign_key => "customer_id"
  belongs_to :worker, :class_name => "Person", :foreign_key => "worker_id"
  belongs_to :req

  validates_presence_of :customer, :worker, :amount, :req

  attr_accessible :amount

  after_create :log_activity

  def log_activity
    add_activities(:item => self, :person => self.worker)
    add_activities(:item => self, :person => self.customer)      # log an exchange under both people, so it shows on both their feeds
  end

  private

  def validate
    unless amount > 0
      errors.add(:amount, "must be greater than zero")
    end
  end
end
