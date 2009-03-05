# == Schema Information
# Schema version: 20090223070356
#
# Table name: categories
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     
#  description :text            
#  parent_id   :integer(4)      
#  created_at  :datetime        
#  updated_at  :datetime        
#

class Category < ActiveRecord::Base

  is_indexed :fields => ['name', 'description']

  has_and_belongs_to_many :reqs
  has_and_belongs_to_many :people
  acts_as_tree

  def all_requests
    req_ids = []
    
    Category.find_all_by_parent_id(self.id).each { |c|
      c.reqs.each {|r| req_ids.concat [r.id] if r.active }
    }
    reqs.each {|r| req_ids.concat [r.id] if r.active }

    Req.find(req_ids)
  end
  
  def num_requests
    all_requests.length
  end

  def ancestors_name
    if parent
      parent.ancestors_name + parent.name + ':'
    else
      ""
    end
  end

  def long_name
    ancestors_name + name
  end
end
