class ThemesEventsController < ApplicationController
  before_filter :auth
  def index
    if params[:locale]
      @themes = ThemesEvent.by_kind(:normal).old.hp.ordered
    else
      @themes = ThemesEvent.ordered
    end
  end

  def show
      @theme = ThemesEvent.find(params[:id])
      @list = ProductList.theme.special_theme(@theme.id).by_language(DVDPost.product_languages[I18n.locale])
  end
  protected

  def auth
    if params[:locale].nil?
      http_authenticate
    end
  end
end
