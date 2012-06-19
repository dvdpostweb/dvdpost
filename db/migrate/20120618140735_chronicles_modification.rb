class ChroniclesModification < ActiveRecord::Migration
  def self.up
    add_column :chronicle_contents, :selected, :boolean, :default => false
    add_column :chronicle_contents, :status, 'enum("TEST","ONLINE","DELETED")'
    add_column :chronicle_contents, :cover_file_name, :string
    add_column :chronicle_contents, :cover_content_type, :string
    add_column :chronicle_contents, :cover_file_size, :integer
    add_column :chronicle_contents, :cover_updated_at, :datetime

    add_index :chronicle_contents, :status
    add_index :chronicle_contents, :selected

    remove_column :chronicles, :selected
    remove_column :chronicles, :cover_file_name
    remove_column :chronicles, :cover_content_type
    remove_column :chronicles, :cover_file_size
    remove_column :chronicles, :cover_updated_at
    
  end

  def self.down
    remove_column :chronicle_contents, :selected
    remove_column :chronicle_contents, :status
    remove_column :chronicle_contents, :cover_file_name
    remove_column :chronicle_contents, :cover_content_type
    remove_column :chronicle_contents, :cover_file_size
    remove_column :chronicle_contents, :cover_updated_at
    
    add_column :chronicles, :selected, :boolean, :default => false
    add_column :chronicles, :cover_file_name, :string
    add_column :chronicles, :cover_content_type, :string
    add_column :chronicles, :cover_file_size, :integer
    add_column :chronicles, :cover_updated_at, :datetime
    
  end
end
