class ChroniclesController < ApplicationController
  def index
    
    @categories = ChronicleCategory.all
    respond_to do |format|
          format.html do
            @page = params[:page] || 1
            if params[:category_id]
              sql = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private : ChronicleCategory.find(params[:category_id]).chronicles.beta
              @chronicle =  sql.ordered.first(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale]}})
              @chronicles =   sql.exclude(@chronicle.to_param).ordered.all(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale]}}).paginate(:per_page => 4, :page => @page)
            else
              sql = Rails.env == 'production' ? Chronicle.private : Chronicle.beta
              @chronicle = sql.selected.ordered.first(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale]}})
              @chronicles = sql.not_selected.ordered.all(:joins =>:contents, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale]}}).paginate(:per_page => 4, :page => @page)
            end
            @nb_page = @chronicles.total_pages
          end
          format.rss do
            @chronicles = Rails.env == 'production' ? Chronicle.private.ordered : Chronicle.beta.ordered
            render :layout => false
          end
      end
  end

  def about
  end

  def show
   @chronicle = Rails.env == 'production' ? Chronicle.private.find(params[:id]) : Chronicle.beta.find(params[:id])
  end
end