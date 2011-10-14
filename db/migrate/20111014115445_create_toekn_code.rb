class CreateToeknCode < ActiveRecord::Migration
  def self.up
    add_column :tokens, :code, :string, :after => :customer_id
  end

  def self.down
    remove_column :tokens, :code
  end
end
