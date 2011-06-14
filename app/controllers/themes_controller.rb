class ThemesController < ApplicationController
  def index
    Rails.logger.debug { "@@@#{params[:page_name]}" }
    if params[:page_name] == 'stvalentin'
      @list = ProductList.theme.special_theme(2).by_language(DVDPost.product_languages[I18n.locale])
      @theme = ThemesEvent.find_by_name(params['page_name'])
      
    elsif params[:page_name] == 'oscars_cesar'
      @list = ProductList.theme.special_theme(3).by_language(DVDPost.product_languages[I18n.locale])
      @theme = ThemesEvent.find_by_name(params['page_name'])
    else
      @theme = ThemesEvent.find_by_name(params['page_name'])
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
    end
  end
end
