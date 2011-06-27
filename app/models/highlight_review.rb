class HighlightReview < ActiveRecord::Base

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => language}}}
  named_scope :ordered, :order => 'rank asc'
  belongs_to :review
end