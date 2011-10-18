class StreamingCode < ActiveRecord::Base
  def available?
    used_at.nil? && expiration_at >= Date.today
  end
end