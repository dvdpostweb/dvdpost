class SearchFiltersController < ApplicationController
  def create
    if params[:search_filter]
      expiration_recommendation_cache()
      get_current_filter(params[:search_filter])
    end
    redirect_to products_path(:view_mode => params[:view_mode], :list_id => params[:list_id], :category_id => params[:category_id], :actor_id => params[:actor_id], :director_id => params[:director_id], :studio_id => params[:studio_id])
  end

  def destroy
    filter = get_current_filter({})
    if filter
      filter.destroy
      current_customer.customer_attribute.update_attributes(:filter_id => nil) if current_customer
      cookies.delete :filter_id
    end
    redirect_back_or(products_path)
  end

  private
  def redirect_back_or(path)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to path
  end
end
