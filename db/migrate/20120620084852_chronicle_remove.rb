class ChronicleRemove < ActiveRecord::Migration
  def self.up
    remove_column :chronicles, :selected
    remove_column :chronicles, :cover_file_name
    remove_column :chronicles, :cover_content_type
    remove_column :chronicles, :cover_file_size
    remove_column :chronicles, :cover_updated_at
  end

  def self.down
    add_column :chronicles, :selected, :boolean, :default => false
    add_column :chronicles, :cover_file_name, :string
    add_column :chronicles, :cover_content_type, :string
    add_column :chronicles, :cover_file_size, :integer
    add_column :chronicles, :cover_updated_at, :datetime
  end
end
