class ChroniclesController < ApplicationController
  def index
    @page = params[:page] || 1
    per_page = 4
    if params[:category_id]
      @chronicle = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.ordered.first : ChronicleCategory.find(params[:category_id]).chronicles.beta.ordered.first
      @chronicles = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.exclude(@chronicle.to_param).ordered.paginate(:per_page => 5, :page => @page) : ChronicleCategory.find(params[:category_id]).chronicles.beta.exclude(@chronicle.to_param).ordered.paginate(:per_page => 5, :page => @page)
      chronicles_count = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.count : ChronicleCategory.find(params[:category_id]).chronicles.beta.count
      
    elsif params[:old]
      @chronicles = Rails.env == 'production' ? Chronicle.private.not_selected.ordered : Chronicle.beta.not_selected.ordered
    else
      @chronicle =  Rails.env == 'production' ? Chronicle.private.selected.ordered.first : Chronicle.selected.beta.ordered.first
      @chronicles = Rails.env == 'production' ? Chronicle.private.not_selected.ordered.paginate(:per_page => @per_page, :page => @page) : Chronicle.beta.not_selected.ordered.paginate(:per_page => 4, :page => @page)
      chronicles_count = Rails.env == 'production' ? Chronicle.private.not_selected.count : Chronicle.beta.not_selected.count
    end
    @categories = ChronicleCategory.all
    @nb_page = (chronicles_count.to_f/per_page.to_f).ceil
  end

  def show
    begin
       @chronicle = Rails.env == 'production' ? Chronicle.private.find(params[:id]) : Chronicle.beta.find(params[:id])
     rescue ActiveRecord::RecordNotFound
       msg = "Attention: chronicles with ID:#{params[:id]} not found in database"
       logger.error(msg)
       flash[:notice] = msg
       redirect_to chronicles_path
     end
  end
end