class CreateNewsletters < ActiveRecord::Migration
  def self.up
    create_table :public_newsletters do |t|
      t.string :email
      t.integer :language_id
      t.timestamps
    end
  end

  def self.down
    drop_table :public_newsletters
  end
end
