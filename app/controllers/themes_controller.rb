class ThemesController < ApplicationController
  def index
    if params[:page_name] == 'stvalentin'
      @list = ProductList.theme.special_theme(2).by_language(DVDPost.product_languages[I18n.locale])
    elsif params[:page_name] == 'oscars_cesar'
      @list = ProductList.theme.special_theme(3).by_language(DVDPost.product_languages[I18n.locale])
    else
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
    end
  end
end
