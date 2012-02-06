class ActorsController < ApplicationController
  def index
    require_dependency "#{Rails.root}/app/models/actor.rb"
    if !params[:letter]
      fragment_name = session[:sexuality] == 1 ? "actors_x_gay_hash" : "actors_x_hetero_hash"
      @actors = when_fragment_expired fragment_name, 1.week.from_now.localtime do
      begin
          @actors = Hash.new()
          ('a'..'z').each do |l|
            details = Hash.new()
            if session[:sexuality] == 1
              actors = Actor.by_kind(:adult).by_sexuality(:gay).by_letter(l).limit(10).ordered
            else
              actors = Actor.by_kind(:adult).by_sexuality(:hetero).with_image.by_letter(l).limit(10).ordered
            end
            if actors.count > 0
              i = 0
              actors.collect do |actor|
                i += 1
                count = Product.search.by_actor(actor.id).available.count
                details[i] = {:actor => actor, :count => count}
              end
              @actors[l] = details
            end
          end
          @actors
        rescue => e
          logger.error "actor unavailable:  {e.message}"
          expire_fragment(fragment_name)
          false
        end
      end
    else
      fragment_name = session[:sexuality] == 1 ?  "actors_x_gay_hash_#{params[:letter]}" : "actors_x_hetero_hash_#{params[:letter]}"
      @actors = when_fragment_expired fragment_name, 1.week.from_now.localtime do
        begin
          @actors = Hash.new()
          details = Hash.new()
          if session[:sexuality] == 1
            actors = Actor.by_kind(:adult).by_sexuality(:gay).by_letter(params[:letter]).ordered
          else
            actors = Actor.by_kind(:adult).by_sexuality(:hetero).by_letter(params[:letter]).ordered
          end
          if actors.count > 0
            i = 0
            actors.collect do |actor|
              i += 1
              count = Product.search.by_actor(actor.id).available.count
              details[i] = {:actor => actor, :count => count}
            end
            @actors[params[:letter]] = details
          end
          @actors
        rescue => e
          logger.error "actor unavailable:  {e.message}"
          expire_fragment(fragment_name)
          false
        end
      end
    end
  end
end