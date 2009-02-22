class AddIsexchangeToReq < ActiveRecord::Migration
  def self.up
    add_column :reqs, :isexchange, :boolean, {:default=>false}
  end

  def self.down
    remove_column :reqs, :isexchange
  end
end
