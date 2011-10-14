class StreamingCode < ActiveRecord::Base
  def not_used?
    used_at.nil?
  end
end
