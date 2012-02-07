class StudiosController < ApplicationController
  def index
    query = params[:filter] && params[:filter].to_sym == :vod ? Studio.by_kind(params[:kind]).vod : Studio.by_kind(params[:kind])
    if !params[:letter]
      @studios = OrderedHash.new()
      @studios_count = OrderedHash.new()
      @studios_count.push(0, query.by_number.count)
      @studios.push(0, query.by_number.limit(10).ordered)
      ('a'..'z').each do |l|
        @studios_count.push(l, query.by_letter(l).count)
        @studios.push(l, query.by_letter(l).limit(10).ordered)
      end
    else
      if params[:letter] == "0"
        @studios = query.by_number.ordered
      else
        @studios = query.by_letter(params[:letter]).ordered
      end
    end
  end
end