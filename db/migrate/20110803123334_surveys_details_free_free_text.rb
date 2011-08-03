class SurveysDetailsFreeFreeText < ActiveRecord::Migration
  def self.up
    add_column :survey_details, :free_text_fr, :string
    add_column :survey_details, :free_text_nl, :string
    add_column :survey_details, :free_text_en, :string
    
  end

  def self.down
    remove_column :survey_details, :free_text_fr, :string
    remove_column :survey_details, :free_text_nl, :string
    remove_column :survey_details, :free_text_en, :string
  end
end
