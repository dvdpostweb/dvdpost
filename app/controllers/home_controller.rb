class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        @body_id = 'one-col'
        @top10 = ProductList.find_by_home_page(true).products
        @soon = Product.by_kind(:normal).available.soon
        @new = Product.by_kind(:normal).available.new_products
        @quizz = QuizzName.find_last_by_focus(1)
        not_rated_products = current_customer.not_rated_products
        @not_rated_product = not_rated_products[rand(not_rated_products.count)]
        @contest = ContestName.by_language(I18n.locale).last
        shops = Banner.by_language(I18n.locale).by_size(:small).expiration
        @shop = shops[rand(shops.count)]
        @wishlist_count = current_customer.wishlist_items.count
        @transit_items_count = current_customer.orders.in_transit.count
        @transit_items = current_customer.orders.in_transit.all(:limit => 2, :order => 'orders.date_purchased ASC')
        @news_items = retrieve_news
        @recommendations = retrieve_recommendations(true)
        @carousel = Landing.by_language(I18n.locale).not_expirated.private.order(:asc).limit(5)
        @carousel += Landing.by_language(I18n.locale).expirated.private.order(:desc).limit(5 - @carousel.count) if @carousel.count < 5
      }
      format.js {
        if params[:news_page]
          render :partial => '/home/index/news', :locals => {:news_items => retrieve_news}
        elsif params[:recommendation_page]
          render :partial => 'home/index/recommendations', :locals => {:products => retrieve_recommendations_for_index}
        end
      }
    end
  end

  def indicator_closed
    session[:indicator_stored] = true
    render :nothing => true
  end

  private
  def retrieve_news
    news_items = when_fragment_expired "#{I18n.locale.to_s}/home/news", 1.hour.from_now do
      DVDPost.home_page_news
    end
    news_items.paginate(:per_page => 3, :page => params[:news_page] || 1)
  end

  def retrieve_recommendations(expire=false)
    name = "#{I18n.locale.to_s}/home/recommendations"
    expire_timed_fragment(name) if expire
    recommended_ids = when_fragment_expired name do
      DVDPost.home_page_recommendations(current_customer)
    end
    Product.filtered_by_ids(recommended_ids).paginate(:per_page => 8, :page => params[:recommendation_page] || 1)
  end
end
