class RenamePpvReadyToPpvStatus < ActiveRecord::Migration
  def self.up
    rename_column :customers, :ppv_ready, :ppv_status_id
    create_table(:ppv_status) do |t|
      t.string :name
      t.timestamps
    end
  end

  def self.down
    rename_column :customers, :ppv_ready, :ppv_status_id
    remove_table :ppv_status
  end
end
