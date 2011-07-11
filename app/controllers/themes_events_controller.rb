class ThemesEventsController < ApplicationController
  def index
    if Rails.env == "pre_production"
      @themes = ThemesEvent.by_kind(:normal).old_beta
    else
      @themes = ThemesEvent.by_kind(:normal).old_beta
    end
  end

  def show
      @theme = ThemesEvent.find(params[:id])
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
  end
end
