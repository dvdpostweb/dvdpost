#############################################################
#	Application
#############################################################

set :application, "dvdpostapp"
set :deploy_to, "/home/webapps/dvdpostapp/production"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "production"

#############################################################
#	Servers
#############################################################

set :user, "dvdpostapp"
set :domain,  "217.112.190.177"
set :domain2, "94.139.62.122"
set :port, 22012
role :web,  domain2
role :app,  domain2
role :db, domain2, :primary => true

#############################################################
#	Git
#############################################################

set :scm, :git
set :branch, "production"
set :scm_user, 'dvdpost'
set :scm_passphrase, "[y'|\E7U158]9*"
set :repository, "git@github.com:dvdpost/dvdpost.git"
set :deploy_via, :remote_cache

#############################################################
#	Passenger
#############################################################
set :whenever_environment, defer { stage }
set :whenever_identifier, defer { "#{application}_#{stage}" }
set :whenever_command, "bundle exec whenever"

require "whenever/capistrano"
namespace :deploy do
  desc "Create the database yaml file"
  after "deploy:update_code" do
    db_config = <<-EOF
    production:
      adapter: mysql
      encoding: utf8
      database: dvdpost_be_prod
      username: webuser
      password: 3gallfir-
      host: 192.168.100.204
      port: 3306
      slave01:
        adapter: mysql
        encoding: utf8
        database: dvdpost_be_prod
        username: webuser
        password: 3gallfir-
        host: 192.168.100.204
        port: 3306
      slave02:
        adapter: mysql
        encoding: utf8
        database: dvdpost_be_prod
        username: webuser
        password: 3gallfir-
        host: 192.168.100.204
        port: 3306
    EOF
    put db_config, "#{release_path}/config/database.yml"
  end
  
  # Restart passenger on deploy
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{current_path}/tmp/restart.txt"
  end
  
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end
end

after "deploy:restart" do
 env_config = <<-EOF
 # Settings specified here will take precedence over those in config/environment.rb

 # The production environment is meant for finished, "live" apps.
 # Code is not reloaded between requests
 config.cache_classes = true

 # Full error reports are disabled and caching is turned on
 config.action_controller.consider_all_requests_local = false
 config.action_controller.perform_caching             = true
# config.cache_store = :file_store, RAILS_ROOT + "/tmp/cache"
 config.cache_store = :mem_cache_store, '192.168.100.204:11211'
 config.action_view.cache_template_loading            = true
 ENV['APP'] = "1"
 # See everything in the log (default is :info)
 # config.log_level = :debug

 # Use a different logger for distributed setups
 # config.logger = SyslogLogger.new

 # Use a different cache store in production
 # config.cache_store = :mem_cache_store

 # Enable serving of images, stylesheets, and javascripts from an asset server
 # config.action_controller.asset_host = "http://assets.example.com"

 # Disable delivery errors, bad email addresses will be ignored
 # config.action_mailer.raise_delivery_errors = false

 # Enable threaded mode
 # config.threadsafe!

  EOF
 put env_config, "#{current_path}/config/environments/production.rb"

end

   
#namespace :deploy do  
#  desc "Update the crontab file"  
#  task :update_crontab, :roles => :db do  
#    run "cd #{release_path} && bundle exec whenever --update-crontab #{application}"  
#  end  
#end

before 'deploy:create_symlink', 'deploy:stop_ts'
after 'deploy:create_symlink', 'deploy:update_ts'
#after 'deploy:create_symlink', 'deploy:update_crontab'

=begin
    production:
      adapter: mysql
      encoding: utf8
      database: dvdpost_be_prod
      username: webuser
      password: 3gallfir-
      host: matadi
      port: 3306
=end