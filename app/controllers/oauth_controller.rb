class OauthController < ApplicationController
  skip_before_filter :authenticate!
  
  def authenticate
    redirect_to oauth_client.web_server.authorize_url(
      :redirect_uri => oauth_callback_url
    )
  end

  def callback
    access_token = oauth_client.web_server.get_access_token(
      params[:code], :redirect_uri => oauth_callback_url
    )
    
    session[:oauth_token] = access_token.token
    attempted_path = session[:attempted_path]
    
    redirect_to attempted_path ? attempted_path : root_path
  end
end
