class TrailerAmerliation < ActiveRecord::Migration
  def self.up
    add_column :products_trailers, :created_at, :date
    add_column :products_trailers, :focus, :boolean
  end

  def self.down
    remove_column :products_trailers, :created_at
    remove_column :products_trailers, :focus
  end
end
