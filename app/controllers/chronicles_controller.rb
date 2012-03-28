class ChroniclesController < ApplicationController
  def index
    if params[:category_id]
      @chronicles = Rails.env == 'production' ? ChronicleCategory.find(params[:category_id]).chronicles.private.ordered.limit(7) : ChronicleCategory.find(params[:category_id]).chronicles.beta.ordered.limit(7)
      @chronicle = @chronicles.delete_at(0)
    elsif params[:old]
      @chronicles = Rails.env == 'production' ? Chronicle.private.not_selected.ordered : Chronicle.beta.not_selected.ordered
    else
      @chronicle =  Rails.env == 'production' ? Chronicle.private.selected.ordered.first : Chronicle.selected.beta.ordered.first
      @chronicles = Rails.env == 'production' ? Chronicle.private.not_selected.ordered.limit(6) : Chronicle.beta.not_selected.ordered.limit(6)
    end
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