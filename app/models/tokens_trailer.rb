class TokensTrailer < ActiveRecord::Base
  named_scope :available, lambda {{:conditions => ['active = ? and expire_at > ?', 1, Time.now]}}
  
end