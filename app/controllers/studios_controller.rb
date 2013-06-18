class StudiosController < ApplicationController
  def index
     @filter = get_current_filter({})
      @countries = ProductCountry.visible.order
    if params[:filter] && params[:filter].to_sym == :vod
      @studios = Studio.by_kind(params[:kind]).ordered
      case session[:country_id]
        when 131
          @studios = @studios.vod_lux
        when 161
          @studios = @studios.vod_nl
        else
          @studios = @studios.vod_be
      end
      
    else
      query = Studio.by_kind(params[:kind])
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
end