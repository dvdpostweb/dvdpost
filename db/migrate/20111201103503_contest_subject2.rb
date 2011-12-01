class ContestSubject2 < ActiveRecord::Migration
  def self.up
    add_column :contest_name, :big_title_fr, :string, :after => :title_fr
    add_column :contest_name, :big_title_nl, :string, :after => :title_nl
    add_column :contest_name, :big_title_en, :string, :after => :title_en
  end

  def self.down
    remove_column :contest_name, :big_title_fr
    remove_column :contest_name, :big_title_nl
    remove_column :contest_name, :big_title_en
  end
end
