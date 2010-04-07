ActionController::Routing::Routes.draw do |map|
  map.root :locale => :fr, :controller => :products, :action => :index # Temporary, should be a homepage action instead

  map.with_options :path_prefix => '/:locale' do |localized|
    # Only the Clearance routes we actually need
    # Clearance::Routes.draw(map) # => If all Clearance routes are needed
    localized.with_options :controller => 'clearance/sessions' do |clearance|
      clearance.resource :session,    :only   => [:new, :create, :destroy]
      clearance.sign_in  'sign_in',   :action => :new
      clearance.sign_out 'sign_out',  :action => :destroy, :method => :delete
    end

    localized.resources :products, :only => [:index, :show]
    localized.resources :wishlist_items, :only => [:index], :as => :wishlist
    localized.wishlist '/wishlist', :controller => :wishlist_items, :action => :index
  end
end
