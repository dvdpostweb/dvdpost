class ActorsController < ApplicationController
  def index
    if !params[:letter]
      fragment_name = "actors_x"
      @actors = when_fragment_expired fragment_name, 1.week.from_now.localtime do
        begin
          @actors = OrderedHash.new()
          ('a'..'z').each do |l|
            details = OrderedHash.new()
            actors = Actor.by_kind(:adult).with_image.by_letter(l).ordered
            if actors.count > 0
              i = 0
              actors.collect do |actor|
                i += 1
                count = Product.search.by_actor(actor.id).available.count
                details.push(i, {:actor => actor, :count => count})
              end
              @actors.push(l, details) 
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
      fragment_name = "actors_x_#{params[:letter]}"
      @actors = when_fragment_expired fragment_name, 1.week.from_now.localtime do
        begin
          @actors = OrderedHash.new()
          details = OrderedHash.new()
          actors = Actor.by_kind(:adult).by_letter(params[:letter]).ordered
          if actors.count > 0
            i = 0
            actors.collect do |actor|
              i += 1
              count = Product.search.by_actor(actor.id).available.count
              details.push(i, {:actor => actor, :count => count})
            end
            @actors.push(params[:letter], details)
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