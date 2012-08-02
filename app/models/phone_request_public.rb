class PhoneRequestPublic < ActiveRecord::Base
  set_table_name :phone_request
  

  validates_format_of :phone, :with => /^(\+)?[0-9 \-\/.]+$/
  validates_presence_of :reason
  validates_presence_of :hour
  validates_presence_of :requested_date

  alias_attribute :reason, :call_me_reason
  alias_attribute :hour, :call_me_hour
  alias_attribute :day, :call_me_day

  def self.time_slots
    slots = OrderedHash.new
    slots.push("9h00 - 9h30", 3)
    slots.push("9h30 - 10h00", 4)
    slots.push("10h00 - 10h30", 5)
    slots.push("10h30 - 11h00", 6)
    slots.push("11h00 - 11h30", 7)
    slots.push("11h30 - 12h00", 8)
    slots.push("12h00 - 12h30", 9)
    slots.push("12h30 - 13h00", 10)
    slots.push("13h00 - 13h30", 11)
    slots.push("13h30 - 14h00", 12)
    slots.push("14h00 - 14h30", 13)
    slots.push("14h30 - 15h00", 14)
    slots.push("15h00 - 15h30", 15)
    slots.push("15h30 - 16h00", 16)
    slots.push("16h00 - 16h30", 17)
    slots.push("16h30 - 17h00", 18)
    slots
  end

  def self.reason_codes
    codes = OrderedHash.new
    codes.push(:send, 7)
    codes.push(:payment, 6)
    codes.push(:admin, 4)
    codes
  end

  def self.languages
    lang = OrderedHash.new
    lang.push(1, :fr)
    lang.push(2, :nl)
    lang.push(3, :en)
    lang
  end

  def requested_date
      day && day > 0? Time.at(day).strftime("%d-%m-%Y") : nil
  end

  def requested_date=(date)
    if date.nil?
        nil 
    else
      regex = /\d{2}-\d{2}-\d{4}/
      if date =~ regex
        self.day = Date.parse(date).to_time.to_i
      else
        nil
      end
    end
  end
end