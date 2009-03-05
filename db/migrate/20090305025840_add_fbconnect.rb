class AddFbconnect < ActiveRecord::Migration
  def self.up
    add_column :people, :facebook_id, :integer
  end

  def self.down
    remove_column :people, :facebook_id
  end
end
