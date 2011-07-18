class CategoriesController < ApplicationController
  def index
    @categories = OrderedHash.new()
    @categories.push(0, Category.by_kind(params[:kind]).ordered.all(:joins => :descriptions, :conditions => ['categories_description.categories_name REGEXP "^[0-9]" and language_id = ?', DVDPost.product_languages[I18n.locale]]))
    ('a'..'z').each do |l|
      @categories.push(l, Category.by_kind(params[:kind]).ordered.all(:joins => :descriptions, :conditions => ['categories_description.categories_name like ? and language_id = ?', l+'%', DVDPost.product_languages[I18n.locale]]))
    end
  end
end