class CreateActivationActions < ActiveRecord::Migration
  def self.up
    create_table(:activation_actions) do |t|
      t.integer   :activation_code_id
      t.integer   :class_id
      t.integer   :customer_id
    end
    add_index :activation_actions, :activation_code_id
  end

  def self.down
    drop_table :activation_actions
  end
end
