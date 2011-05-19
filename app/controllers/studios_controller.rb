class StudiosController < ApplicationController
  def index
    if !params[:letter]
      @studios = OrderedHash.new()
      @studios_count = OrderedHash.new()
      @studios_count.push(0, Studio.by_kind(params[:kind]).by_number.count)
      @studios.push(0, Studio.by_kind(params[:kind]).by_number.limit(10))
      ('a'..'z').each do |l|
        @studios_count.push(l, Studio.by_kind(params[:kind]).by_letter(l).count)
        @studios.push(l, Studio.by_kind(params[:kind]).by_letter(l).limit(10))
      end
    else
      if params[:letter] == "0"
        @studios = Studio.by_kind(params[:kind]).by_number
      else
        @studios = Studio.by_kind(params[:kind]).by_letter(params[:letter])
      end
    end
  end
end