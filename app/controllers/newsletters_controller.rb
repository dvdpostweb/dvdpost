class NewslettersController < ApplicationController

  def index
    status = Rails.env == 'production' ? 'ONLINE' : ['ONLINE','TEST']
    respond_to do |format|
      format.html do
        @cat = params[:category_id] || 1
        sql = Rails.env == 'production' ? NewsCategory.find(@cat).news.private : NewsCategory.find(@cat).news.beta
        @news_first =  sql.by_kind(params[:kind]).ordered.first(:joins =>:contents, :conditions => { :news_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}})
        @news =   sql.exclude(@news_first.to_param).ordered.all(:joins =>:contents, :conditions => { :news_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}})
      end
    end
  end

  def show
    status = Rails.env == 'production' ? 'ONLINE' : ['ONLINE','TEST']
    respond_to do |format|
      format.html do
        @news = Rails.env == 'production' ? News.private.find(params[:id]) : News.beta.find(params[:id])
        if @news
          @content = @news.contents.by_language(I18n.locale).first 
          @cat = @news.category.to_param
        end
      end
    end
  end

end
