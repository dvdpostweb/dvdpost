class CreateSurveys < ActiveRecord::Migration
  def self.up
    create_table :surveys do |t|
      t.string :title_fr
      t.string :title_nl
      t.string :title_en
      t.integer :survey_kind_id, :default => 1
      t.integer :total_rating, :default => 0
      t.integer :themes_event_id, :default => 0
      t.timestamps
    end

    create_table :survey_kinds do |t|
      t.string :name
      t.timestamps
    end

    create_table :customer_surveys do |t|
      t.references :customer
      t.references :survey
      t.integer :response
      t.timestamps
    end
    add_index :customer_surveys, :customer_id
    add_index :customer_surveys, :survey_id

    create_table :survey_details do |t|
      t.references :survey
      t.integer :reference_id
      t.integer :rating, :default => 0
      t.timestamps
    end
    
    
  end

  def self.down
    drop_table :surveys
    drop_table :survey_kinds
    drop_table :survey_details
    drop_table :customer_surveys
  end
end
