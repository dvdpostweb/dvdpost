class PhoneRequestName < ActiveRecord::Migration
  def self.up
    add_column :phone_custserv, :name, :string, :after => false, :after => :customer_id
  end

  def self.down
    remove_column :phone_custserv, :name
  end
end
