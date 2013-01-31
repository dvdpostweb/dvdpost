class PublicNewslettersController < ApplicationController
  def new
    @newsletter = PublicNewsletter.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    @newsletter = PublicNewsletter.new(params[:public_newsletter])
    if @newsletter.save
      products_seen_read.each do |product|
        @newsletter.public_newsletter_products.create(:product_id =>product)
      end
      
      cookies[:public_newsletter_id] = { :value => @newsletter.to_param, :expires => 2.months.from_now }
      flash[:notice] = t('.public_newsletters.create.email_save')
      respond_to do |format|
        format.html {redirect_to root_path(:promo => params[:promo])}
        format.js {render :layout => false}
      end
    else
      respond_to do |format|
        format.html {render :action => :new }
        format.js {render :action => :new, :layout => false}
      end
    end
  end
end