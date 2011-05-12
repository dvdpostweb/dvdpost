module ActorsHelper
  def cached_actors(letter)

    fragment_name = "actor_html11_#{letter}"
    @actors_html = when_fragment_expired fragment_name, 1.week.from_now do
      begin
          data =''
          Actor.by_kind(:adult).limit(100).collect do |actor|
            data += "#{actor.name} (#{actor.products.count})<br />"
          end
          data 
      rescue => e
        logger.error "Homepage recommendations unavailable: #{e.message}"
        expire_fragment(fragment_name)
        false
      end
    end


  end
end
