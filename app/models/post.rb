# == Schema Information
# Schema version: 20090223070356
#
# Table name: posts
#
#  id         :integer(4)      not null, primary key
#  blog_id    :integer(4)      
#  topic_id   :integer(4)      
#  person_id  :integer(4)      
#  title      :string(255)     
#  body       :text            
#  type       :string(255)     
#  created_at :datetime        
#  updated_at :datetime        
#

class Post < ActiveRecord::Base
  include ActivityLogger
  has_many :activities, :foreign_key => "item_id", :dependent => :destroy
  attr_accessible nil
end
