class ChroniclesController < ApplicationController
  def index
    
    @categories = ChronicleCategory.all
    respond_to do |format|
          format.html do
            @page = params[:page] || 1
            if params[:category_id]
              @chronicle = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.ordered.first : ChronicleCategory.find(params[:category_id]).chronicles.beta.ordered.first
              @chronicles = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.exclude(@chronicle.to_param).ordered.paginate(:per_page => 4, :page => @page) : ChronicleCategory.find(params[:category_id]).chronicles.beta.exclude(@chronicle.to_param).ordered.paginate(:per_page => 4, :page => @page)
              chronicles_count = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.count : ChronicleCategory.find(params[:category_id]).chronicles.beta.count
              @nb_page = ((chronicles_count.to_f)/4.0).ceil
            else
              @chronicle =  Rails.env == 'production' ? Chronicle.private.selected.ordered.first : Chronicle.selected.beta.ordered.first
              @chronicles = Rails.env == 'production' ? Chronicle.private.not_selected.ordered.paginate(:per_page => 4, :page => @page) : Chronicle.beta.not_selected.ordered.paginate(:per_page => 4, :page => @page)
              chronicles_count = Rails.env == 'production' ? Chronicle.private.not_selected.count : Chronicle.beta.not_selected.count
              @nb_page = ((chronicles_count.to_f)/4.0).ceil

            end
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