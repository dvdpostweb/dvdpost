class ThemesEventsController < ApplicationController
  def index
      @themes = ThemesEvent.by_kind(:normal).old
  end

  def show
      @theme = ThemesEvent.find(params[:id])
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
  end
end
