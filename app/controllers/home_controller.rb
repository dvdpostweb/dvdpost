class HomeController < ApplicationController
  def index
    @body_id = 'one-col'
    @recommendations = Product.find(555,108794,421,104426,54,120399,58,59)
    @soon = Product.find(555,108794,421)
    @new = Product.find(555,108794,421)
  
    @quizz=QuizzName.find_last_by_focus(1)
    @contest=ContestName.by_language(I18n.locale).last
    
    shops=Banner.by_language(I18n.locale).by_size(:small).expiration
    shop_count=shops.count
    i=rand(shop_count)
    @shop=shops[i]
  end

  def indicator_closed
    session[:indicator_stored] = true
    render :nothing => true
  end
end
