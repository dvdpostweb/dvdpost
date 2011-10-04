ActionController::Routing::Routes.draw do |map|
  map.root :controller => :home, :action => :index, :conditions => {:method => :get}
  map.resources :locales, :except => [:show], :member => {:reload => :post} do |locale|
    locale.resources :translations, :except => [:show], :member => {:update_in_place => :post}
  end

  map.with_options :controller => :oauth do |oauth|
    oauth.oauth_authenticate 'oauth/authenticate', :action => :authenticate, :conditions => {:method => :get}
    oauth.oauth_callback 'oauth/callback', :action => :callback, :conditions => {:method => :get}
    oauth.sign_out 'sign_out', :action => :sign_out, :conditions => {:method => :get}
  end
  map.resources :landings, :only => [:index] do |landing|
    landing.resource :texts
  end
  map.resources :themes, :controller => "themes_events", :only => [:index] do |theme|
    theme.resource :texts
  end

  map.with_options :path_prefix => '/:locale/:kind' do |localized|
    localized.filter "kind"
    localized.root :controller => :home, :action => :index, :conditions => {:method => :get}

    localized.with_options :controller => :home do |home|
      home.indicator_close 'home/indicator_close', :action => :indicator_close, :conditions => {:method => :get}
      home.news 'home/news', :action => :news, :conditions => {:method => :get}
    end

    

    localized.resources :products, :only => [:index, :show] do |product|
      product.resource :rating, :only => :create
      product.resources :wishlist_items, :only => [:new, :create]
      product.resources :tokens, :only => [:new, :create]
      product.rating 'rating', :controller => :ratings, :action => :create, :conditions => {:method => :get} # This one is the same as above. Used for the views (GET)
      product.seen 'seen', :controller => :products, :action => :seen
      product.uninterested 'uninterested', :controller => :products, :action => :uninterested
    end

    localized.resources :movies, :only => [:index, :show] do |movie|
      movie.resource :rating, :only => :create
      movie.resources :reviews, :only => [:new, :create]
      movie.resources :wishlist_items, :only => [:new, :create]
      movie.resources :tokens, :only => [:new, :create]
      movie.drop_cached 'drop_cached',  :controller => :movies, :action => :drop_cached, :conditions => {:method => :get} 
      movie.rating 'rating', :controller => :ratings, :action => :create, :conditions => {:method => :get} # This one is the same as above. Used for the views (GET)
      movie.awards 'awards', :controller => :movies, :action => :awards
      movie.seen 'seen', :controller => :products, :action => :seen
      movie.trailer 'trailer', :controller => :movies, :action => :trailer, :conditions => {:method => :get}
      movie.uninterested 'uninterested', :controller => :movies, :action => :uninterested
    end

    localized.resources :streaming_products, :only => [:show], :requirements => { :id => /\d+/ } do |stream|
      stream.faq 'faq', :controller => :streaming_products, :action => :faq, :conditions => {:method => :get}
      stream.resource :report, :controller => :streaming_reports, :only => [:new, :create]
    end

    localized.resource :streaming_products, :only => [] do |stream|
      stream.faq 'faq', :controller => :streaming_products, :action => :faq, :conditions => {:method => :get}
    end

    localized.resources :categories, :only => [:index] do |category|
      category.resources :products, :only => :index
      category.resources :movies, :only => :index
    end

    localized.resources :actors, :only => [:index] do |actor|
      actor.resources :movies, :only => :index
      actor.resources :products, :only => :index
      
    end

    localized.resources :directors, :only => [] do |director|
      director.resources :products, :only => :index
      director.resources :movies, :only => :index
      
    end

    localized.resources :studios, :only => [:index] do |studio|
      studio.resources :products, :only => :index
    end

    localized.resources :collections, :only => [:index] do |collection|
      collection.resources :products, :only => :index
    end

    localized.resources :lists, :only => [] do |top|
      top.resources :products, :only => :index
    end

    localized.resources :reviews, :only => [:show] do |review|
      review.resource :review_rating, :only => :create
    end

    localized.resources :contests, :only => [:new, :create, :index]
    localized.resources :quizzes, :only => [:show, :index]
    
    localized.menu_tops 'menu_tops', :controller => :products, :action => :menu_tops, :conditions => {:method => :get}
    localized.validation 'validation', :controller => :home, :action => :validation, :conditions => {:method => :get}
    localized.menu_categories 'menu_categories', :controller => :products, :action => :menu_categories, :conditions => {:method => :get}
    

    localized.resources :wishlist_items, :only => [:new, :create, :update, :destroy]
    localized.bluray_owner 'wishlist/bluray_owner', :controller => :wishlist_items, :action => :bluray_owner, :conditions => {:method => :get}
    
    localized.wishlist 'wishlist', :controller => :wishlist_items, :action => :index, :conditions => {:method => :get}
    localized.wishlist_start 'wishlist_start', :controller => :wishlist_items, :action => :start, :conditions => {:method => :get}

    localized.resources :messages, :requirements => { :id => /\d+/ }
    localized.resource :messages, :only => [] do |message|
      message.urgent 'urgent', :controller => :messages, :action => :urgent, :conditions => {:method => :get}
    end

    localized.resources :phone_requests, :only => [:new, :create]
    localized.resources :cable_orders, :only => [:create, :new]

    localized.faq 'faq', :controller => :messages, :action => :faq

    localized.resources :orders, :only => [] do |orders|
      #orders.resource :report, :only => [:new, :create]
      #orders.report 'report', :controller => :reports, :action => :create, :conditions => {:method => :get} # This one is the same as above. Used for the views (GET)
    end

    localized.resources :partners
    localized.resources :surveys, :only => [:show] do |survey|
      survey.resources :customer_surveys, :only => [:new, :create]
    end

    localized.resources :tickets do |ticket|
      ticket.resources :message_tickets, :only => [:create]
    end

    localized.info '/info/:page_name' , :controller => :info
    #localized.themes '/themes/:page_name' , :controller => :themes
    localized.resources 'themes', :controller => :themes_events, :only => [:index, :show]

    localized.resources :customers, :only => [:show, :edit, :update] do |customer|
      customer.newsletter 'newsletter', :controller => :customers, :action => :newsletter, :only => [:update]
      customer.mail_copy 'mail_copy', :controller => :customers, :action => :mail_copy, :only => [:update]
      customer.newsletters_x 'newsletters_x', :controller => :customers, :action => :newsletters_x, :only => [:update]
      customer.newsletter_x 'newsletter_x', :controller => :customers, :action => :newsletter_x, :conditions => {:method => :get}
      customer.rotation_dvd 'rotation_dvd', :controller => :customers, :action => :rotation_dvd, :only => [:update]
      customer.sexuality 'sexuality', :controller => :customers, :action => :sexuality, :only => [:update]
      customer.resource 'addresses', :only => [:edit, :update, :create]
      customer.resource 'suspension', :only => [:new, :create, :destroy]
      customer.resource 'reconduction', :only => [:edit, :update]
      customer.resource 'subscription', :only => [:edit, :update]
      customer.resource :customer_attribute, :only => [:edit, :update]
      customer.resources :images, :only => [:new, :create]
      customer.avatar 'avatar', :controller => :avatars, :action => :avatar, :conditions => {:method => :get}
      customer.avatar_pending 'avatar_pending', :controller => :avatars, :action => :avatar_pending, :conditions => {:method => :get}
      customer.resource 'promotion', :only => [:show, :edit]
      customer.resource :payment_methods, :only => [:edit, :update, :show]
      customer.resources :reviews, :only => [:index]
      
      
    end

    localized.resources :search_filters, :only => [:create, :destroy]

    localized.resource :sponsorships do |sponsorship|
      sponsorship.gifts 'gifts', :controller => :sponsorships, :action => :gifts, :conditions => {:method => :get}
      sponsorship.promotion 'promotion', :controller => :sponsorships, :action => :promotion, :conditions => {:method => :get}
      sponsorship.resource :email, :controller => :sponsorships_emails, :only => [:create]
      sponsorship.resource :gifts_history, :only => [:create]
      sponsorship.faq 'faq', :controller => :sponsorships, :action => :faq, :conditions => {:method => :get}
      sponsorship.resource :additional_card, :only => [:new, :create]
    end

  end
  
  #map.get_authentication 'authentication/api/Authenticate', :controller => :authentication, :action => :ok, :conditions => { :method => :get }
  
  
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

