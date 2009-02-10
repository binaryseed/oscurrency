class AddIsofferToReq < ActiveRecord::Migration
  def self.up
    add_column :reqs, :isoffer, :boolean, {:default => false}
  end

  def self.down
    remove_column :reqs, :isoffer
  end
end
