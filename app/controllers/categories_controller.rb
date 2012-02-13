class CategoriesController < ApplicationController
  def index
    query = params[:filter] && params[:filter].to_sym == :vod ? Category.roots.movies.vod.by_kind(params[:kind]) : Category.roots.movies.by_kind(params[:kind])
    @filter = get_current_filter({})
    @countries = ProductCountry.visible.order
    @categories = OrderedHash.new()
    if params[:kind] == :adult
      @categories.push(0, query.all(:joins => :descriptions, :conditions => ['categories_description.categories_name REGEXP "^[0-9]" and language_id = ?', DVDPost.product_languages[I18n.locale]]) )
      ('a'..'z').each do |l|
        @categories.push(l, query.alphabetic_orderd.all(:joins => :descriptions, :conditions => ['categories_description.categories_name like ? and language_id = ?', l+'%', DVDPost.product_languages[I18n.locale]]))
      end
    else
      @categories = query.active.alphabetic_orderd.all(:joins => :descriptions, :conditions => ['language_id = ?', DVDPost.product_languages[I18n.locale]]) 
    end
  end
end