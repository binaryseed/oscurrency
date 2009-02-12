class AddDescriptionToBid < ActiveRecord::Migration
  def self.up
    add_column :bids, :description, :text
  end

  def self.down
    remove_column :bids, :description
  end
end
