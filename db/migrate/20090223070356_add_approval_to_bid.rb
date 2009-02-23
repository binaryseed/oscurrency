class AddApprovalToBid < ActiveRecord::Migration
  def self.up
    add_column :bids, :approval, :boolean
    add_column :bids, :feedback, :text
  end

  def self.down
    remove_column :bids, :approval
    remove_column :bids, :feedback
  end
end
