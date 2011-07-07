class ErrorController < ActionController::Base
  def bad_route
    params[:path].each do |path|
      if path == 'avatars'
        image_url = "#{Rails.root}/public/images/user-thumb.png"
        response.headers['Cache-Control'] = "public, max-age=#{12.hours.to_i}"
          response.headers['Content-Type'] = 'image/jpeg'
          response.headers['Content-Disposition'] = 'inline'
          render :text => open(image_url).read
        break
      end
    end
       
   end
end