class StudiosController < ApplicationController
  def index
    if !params[:letter]
      @studios = OrderedHash.new()
      @studios_count = OrderedHash.new()
      @studios_count.push(0, Studio.by_kind(params[:kind]).by_number.count)
      @studios.push(0, Studio.by_kind(params[:kind]).by_number.limit(10).ordered)
      ('a'..'z').each do |l|
        @studios_count.push(l, Studio.by_kind(params[:kind]).by_letter(l).count)
        @studios.push(l, Studio.by_kind(params[:kind]).by_letter(l).limit(10).ordered)
      end
    else
      if params[:letter] == "0"
        @studios = Studio.by_kind(params[:kind]).by_number.ordered
      else
        @studios = Studio.by_kind(params[:kind]).by_letter(params[:letter]).ordered
      end
    end
  end
end