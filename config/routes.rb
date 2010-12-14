ActionController::Routing::Routes.draw do |map|
  map.root :controller => :home, :action => :index, :conditions => {:method => :get}

  map.resources :locales, :except => [:show], :member => {:reload => :post} do |locale|
    locale.resources :translations, :except => [:show], :member => {:update_in_place => :post}
  end

  map.with_options :controller => :oauth do |oauth|
    oauth.oauth_authenticate 'oauth/authenticate', :action => :authenticate, :conditions => {:method => :get}
    oauth.oauth_callback     'oauth/callback',     :action => :callback,     :conditions => {:method => :get}
    oauth.sign_out           'sign_out',           :action => :sign_out,     :conditions => {:method => :get}
  end

  map.with_options :path_prefix => '/:locale' do |localized|
    localized.root :controller => :home, :action => :index, :conditions => {:method => :get}

    localized.with_options :controller => :home do |home|
      home.indicator_close 'home/indicator_close', :action => :indicator_close, :conditions => {:method => :get}
      home.news 'home/news', :action => :news, :conditions => {:method => :get}
    end

    localized.resources :products, :only => [:index, :show] do |product|
      product.resource  :rating,         :only => :create
      product.resources :reviews,        :only => [:new, :create]
      product.resources :wishlist_items, :only => [:new, :create]
      product.resources :tokens, :only => [:new, :create]
      
      product.rating       'rating',       :controller => :ratings,  :action => :create, :conditions => {:method => :get} # This one is the same as above. Used for the views (GET)
      product.awards       'awards',       :controller => :products, :action => :awards
      product.seen         'seen',         :controller => :products, :action => :seen
      product.trailer      'trailer',      :controller => :products, :action => :trailer, :conditions => {:method => :get}
      product.uninterested 'uninterested', :controller => :products, :action => :uninterested
    end
    localized.resources :streaming_products, :only => [:show] do |stream|
      stream.faq 'faq', :controller => :streaming_products, :action => :faq, :conditions => {:method => :get}
      stream.resource :report, :controller => :streaming_reports, :only => [:new, :create]
    end 

    localized.resources :categories, :only => [] do |category|
      category.resources :products, :only => :index
    end

    localized.resources :actors, :only => [] do |actor|
      actor.resources :products, :only => :index
    end

    localized.resources :directors, :only => [] do |director|
      director.resources :products, :only => :index
    end

    localized.resources :lists, :only => [] do |top|
      top.resources :products, :only => :index
    end

    localized.resources :reviews, :only => [] do |review|
      review.resource :review_rating, :only => :create
    end

    localized.resources :contests, :only => [:new, :create, :index]
    localized.resources :quizzes,  :only => [:show, :index]
    
    localized.menu_tops 'menu_tops', :controller => :products, :action => :menu_tops, :conditions => {:method => :get}
    localized.menu_categories 'menu_categories', :controller => :products, :action => :menu_categories, :conditions => {:method => :get}
    

    localized.resources :wishlist_items, :only => [:new, :create, :update, :destroy]
    localized.wishlist 'wishlist', :controller => :wishlist_items, :action => :index, :conditions => {:method => :get}
    localized.wishlist_start 'wishlist_start', :controller => :wishlist_items, :action => :start, :conditions => {:method => :get}

    localized.resources :messages, :requirements => { :id => /\d+/ }
    localized.resource :messages, :only => [] do |message|
      message.urgent 'urgent', :controller => :messages, :action => :urgent, :conditions => {:method => :get}
    end

    localized.resources :phone_requests, :only => [:new, :create]

    localized.faq 'faq', :controller => :messages, :action => :faq

    localized.resources :orders, :only => [] do |orders|
      orders.resource :report, :only => [:new, :create]
      orders.report 'report', :controller => :reports, :action => :create, :conditions => {:method => :get} # This one is the same as above. Used for the views (GET)
    end

    localized.resources :partners

    localized.info '/info/:page_name' , :controller => :info

    localized.resources :customers, :only => [:show, :edit, :update] do |customer|
      customer.newsletter 'newsletter', :controller => :customers, :action => :newsletter, :only => [:update]
      customer.rotation_dvd 'rotation_dvd', :controller => :customers, :action => :rotation_dvd, :only => [:update]
      customer.resource 'addresses', :only => [:edit, :update]
      customer.resource 'suspension', :only => [:new, :create, :destroy]
      customer.resource 'reconduction', :only => [:edit, :update]
      customer.resources :reviews, :only => [:index]
      
      
    end

    localized.resources :filters, :only => [:create, :destroy]

    localized.resource :sponsorships do |sponsorship|
      sponsorship.gifts 'gifts', :controller => :sponsorships, :action => :gifts, :conditions => {:method => :get}
      sponsorship.promotion 'promotion', :controller => :sponsorships, :action => :promotion, :conditions => {:method => :get}
      sponsorship.resource :email, :controller => :sponsorships_emails, :only => [:create]
      sponsorship.resource :gifts_history, :only => [:create]
      sponsorship.faq 'faq', :controller => :sponsorships, :action => :faq, :conditions => {:method => :get}
      sponsorship.resource :additional_card, :only => [:new, :create]
    end

  end
  
  map.get_authentication 'authentication/api/Authenticate', :controller => :authentication, :action => :ok, :conditions => { :method => :get }
  
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  
end
