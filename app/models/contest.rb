class Contest < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :contest

  set_primary_key :contest_id

  named_scope :winner, :conditions => {:is_a_winner => 1}

  db_magic :slave => :slave01 if ENV['APP'] == "1"

  validates_numericality_of :contest_name_id

  belongs_to :customer, :foreign_key => :customers_id

  def validate
    errors.add({}, "Make a choice") if self.answer_id.nil? || self.answer_id > 4 || self.answer_id <= 0
  end
end
