class ChroniclesController < ApplicationController
  def index
    @categories = ChronicleCategory.all
    respond_to do |format|
      status = Rails.env == 'production' ? 'ONLINE' : ['ONLINE','TEST']
      format.html do
        @page = params[:page] || 1
        if params[:category_id]
          sql = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private : ChronicleCategory.find(params[:category_id]).chronicles.beta
          @chronicle =  sql.ordered.first(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}})
          @chronicles =   sql.exclude(@chronicle.to_param).ordered.all(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}}).paginate(:per_page => 4, :page => @page)
        else
          sql = Rails.env == 'production' ? Chronicle.private : Chronicle.beta
          @chronicle = sql.ordered.first(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :selected => true, :status => status}})
          @chronicles = sql.ordered.all(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :selected => false, :status => status}}).paginate(:per_page => 4, :page => @page)
        end
        @nb_page = @chronicles.total_pages
      end
      format.rss do
        sql = Rails.env == 'production' ? Chronicle.private : Chronicle.beta
        @chronicles = sql.ordered.all(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}})
        render :layout => false
      end
    end
  end

  def about
  end

  def show
   @chronicle = Rails.env == 'production' ? Chronicle.private.find(params[:id]) : Chronicle.beta.find(params[:id])
  end
  
  def create
  end
  
  def new
  end
  
  def archive
    status = Rails.env == 'production' ? 'ONLINE' : ['ONLINE','TEST']
    sql = Rails.env == 'production' ? Chronicle.private : Chronicle.beta
    @contents = Hash.new()
    ('a'..'z').each do |letter|
      @contents[letter] =  sql.ordered.all(:joins =>:contents, :conditions => ['language_id = ? and chronicle_contents.status in (?) and title like ?', DVDPost.product_languages[I18n.locale], status, letter+'%'])
    end
  end
end