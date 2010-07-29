Rails.configuration.middleware.use RailsWarden::Manager, :defaults               => :dvdpost_oauth,
                                                         :failure_app            => 'oauth_controller',
                                                         :unauthenticated_action => :authenticate do |manager|
  manager.oauth(:dvdpost) do |sso_dvdpost|
    params = OAUTH.clone

    sso_dvdpost.client_secret = params.delete(:client_secret)
    sso_dvdpost.client_id = params.delete(:client_id)
    sso_dvdpost.options = params
  end
end

# Setup Session Serialization
class Warden::SessionSerializer
  def serialize(record)
    [record.class, record.id]
  end
  
  def deserialize(keys)
    klass, id = keys
    klass.find(:first, :conditions => {klass.primary_key => id})
  end
end

Warden::OAuth2.user_finder(:dvdpost) do |user_id|
  Customer.find(user_id)
end

Warden::Manager.after_set_user do |user, auth, opts|
  strategy = Warden::Strategies[:dvdpost_oauth]
  strategy.validate_token!(auth.raw_session, auth.request.parameters)
end
