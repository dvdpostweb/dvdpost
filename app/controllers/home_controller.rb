class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        @top10 = ProductList.top.by_language(DVDPost.product_languages[I18n.locale]).find_by_home_page(true).products.all(:include => [:director, :actors], :limit=> 10)
        @top_title = ProductList.top.by_language(DVDPost.product_languages[I18n.locale]).find_by_home_page(true).name
        @soon = Product.by_kind(:normal).available.soon.random.limit(3)
        @recent = Product.by_kind(:normal).available.recent.random.limit(3)
        @quizz = QuizzName.find_last_by_focus(1)
        @offline_request = current_customer.payment_offline_request.recovery
        if @offline_request.count == 0
          if current_customer.credit_empty?
            @renew_subscription = true
          else
            not_rated_products = current_customer.not_rated_products
            @not_rated_product = not_rated_products[rand(not_rated_products.count)]
          end
        end
        @contest = ContestName.by_language(I18n.locale).by_date.ordered.first
        shops = Banner.by_language(I18n.locale).by_size(:small).expiration
        @shop = shops[rand(shops.count)]
        @transit_items = current_customer.orders.in_transit.all(:include => :product, :order => 'orders.date_purchased ASC')
        begin
          @news_items = retrieve_news
        rescue => e
          logger.error("Failed to retrieve news: #{e.message}")
        end
        @recommendations = retrieve_recommendations
        @popular = retrieve_popular
        
        @carousel = Landing.by_language(I18n.locale).not_expirated.private.order(:asc).limit(5)
        @carousel += Landing.by_language(I18n.locale).expirated.private.order(:desc).limit(5 - @carousel.count) if @carousel.count < 5
        @streaming_available = current_customer.get_all_tokens
        @filter = current_customer.filter || current_customer.build_filter
      }
      format.js {
        if params[:news_page]
          render :partial => '/home/index/news', :locals => {:news_items => retrieve_news}
        elsif params[:recommendation_page]
          render :partial => 'home/index/recommendations', :locals => {:products => retrieve_recommendations}
        elsif params[:popular_page]
          render :partial => 'home/index/popular', :locals => {:products => retrieve_popular}
        end
      }
    end
  end

  def indicator_close
    current_customer.inducator_close(params[:status])
    render :nothing => true
  end

  private
  def retrieve_news
    fragment_name = "#{I18n.locale.to_s}/home/news"
    news_items = when_fragment_expired fragment_name, 1.hour.from_now do
      begin
        DVDPost.home_page_news
      rescue => e
        logger.error "Homepage news unavailable: #{e.message}"
        expire_fragment_with_meta(fragment_name)
        nil
      end
    end
    news_items.paginate(:per_page => 3, :page => params[:news_page] || 1) if news_items
  end

  def retrieve_recommendations
    current_customer.recommendations({:per_page => 8, :page => params[:recommendation_page]})
  end

  def retrieve_popular
    current_customer.popular.paginate(:per_page => 8, :page => params[:popular_page])
  end

end
