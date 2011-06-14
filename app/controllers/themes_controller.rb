class ThemesController < ApplicationController
  def index
      @theme = ThemesEvent.find_by_name(params['page_name'])
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
  end
end
