class CreateActivationClasses < ActiveRecord::Migration
  def self.up
     create_table(:activation_classes) do |t|
       t.string   :name
       t.string   :description
    end
  end

  def self.down
    drop_table :activation_classes
  end
end
