require 'RMagick'

class ImagesController < ApplicationController
  
  def create
    if params[:images] && params[:images][:face]
      name = params[:images][:face].original_filename
      directory = "#{Rails.root}/public/images/avatars/waiting"
      path = File.join(directory, name)
      File.open(path, "wb") { |f| f.write(params[:images][:face].read) }
      image = Magick::Image.read(path).first
      image.change_geometry!("100x100") { |cols, rows, img|
          newimg = img.resize(cols, rows)
          #name = "#{current_customer.to_param}.jpg"
          #path2 = File.join(directory, name)
          #newimg.write(path2)
          #img2 = Magick::Image.read(path2).first
          current_customer.customer_attribute.update_attribute(:avatar_pending, newimg.to_blob)
          img.destroy!
          #img2.destroy!
      }
      File.delete(path)
      flash[:notice] = t('images.create.success')
    else
      flash[:error] = t('images.create.not_sucess')
    end  

    respond_to do |format|
      format.html {redirect_to customer_path(:id => current_customer.to_param)}
      format.js {render :partial => 'customers/show/avatar', :locals => { :customer => customer }}
    end
  end

  def new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end