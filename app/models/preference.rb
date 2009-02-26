# == Schema Information
# Schema version: 20090223070356
#
# Table name: preferences
#
#  id                        :integer(4)      not null, primary key
#  domain                    :string(255)     default(""), not null
#  smtp_server               :string(255)     default(""), not null
#  email_notifications       :boolean(1)      not null
#  email_verifications       :boolean(1)      not null
#  created_at                :datetime        
#  updated_at                :datetime        
#  analytics                 :text            
#  server_name               :string(255)     
#  app_name                  :string(255)     
#  about                     :text            
#  demo                      :boolean(1)      
#  whitelist                 :boolean(1)      
#  gmail                     :string(255)     
#  exception_notification    :string(255)     
#  registration_notification :boolean(1)      
#  practice                  :text            
#  steps                     :text            
#  questions                 :text            
#  memberships               :text            
#  contact                   :text            
#

class Preference < ActiveRecord::Base
  attr_accessible :app_name, :server_name, :domain, :smtp_server, 
                  :exception_notification,
                  :email_notifications, :email_verifications, :analytics,
                  :about, :demo, :whitelist, :gmail, :registration_notification,
                  :practice, :steps, :questions, :memberships, :contact

  validates_presence_of :domain,       :if => :using_email?
  validates_presence_of :smtp_server,  :if => :using_email?
  
  # Can we send mail with the present configuration?
  def can_send_email?
    not (domain.blank? or smtp_server.blank?)
  end
  
  private
  
    def using_email?
      email_notifications? or email_verifications?
    end
end
