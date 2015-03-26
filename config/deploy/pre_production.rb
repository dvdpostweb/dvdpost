#############################################################
#	Application
#############################################################

set :application, "dvdpostapp"
set :deploy_to, "/home/webapps/dvdpostapp/pre_production"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "pre_production"

#############################################################
#	Servers
#############################################################

set :user, "dvdpostapp"
set :domain,  "94.139.62.122"
set :domain2, "94.139.62.123"
set :port, 22012
role :web, domain, domain2
role :app, domain, domain2
role :db, domain, :primary => true

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

namespace :deploy do
  desc "Create the database yaml file"
  after "deploy:update_code" do
    db_config = <<-EOF
    common_pre_production:
     adapter: mysql
     encoding: utf8
     database: common_production
     username: webuser
     password: 3gallfir-
     host: matadi
     port: 3306
    pre_production:
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
  after "deploy:restart" do
   env_config = <<-EOF
    # Settings specified here will take precedence over those in config/environment.rb
  
    # In the development environment your application's code is reloaded on
    # every request.  This slows down response time but is perfect for development
    # since you don't have to restart the webserver when you make code changes.
    config.cache_classes = false
  
    # Log error messages when you accidentally call methods on nil.
    config.whiny_nils = true
  
    # Show full error reports and disable caching
    config.action_controller.consider_all_requests_local = true
    config.action_view.debug_rjs                         = true
    config.action_controller.perform_caching             = true
    #config.cache_store = :file_store, RAILS_ROOT + "/tmp/cache"
    config.cache_store = :mem_cache_store, '192.168.100.206:11211'
    # Don't care if the mailer can't send
    config.action_mailer.raise_delivery_errors = false
    ENV['APP'] = "1"
    EOF
   put env_config, "#{current_path}/config/environments/pre_production.rb"
 
  end
end
before 'deploy:create_symlink', 'deploy:stop_ts'
after 'deploy:create_symlink', 'deploy:update_ts'


=begin
    pre_production:
      adapter: mysql
      encoding: utf8
      database: dvdpost_be_prod
      username: webuser
      password: 3gallfir-
      host: matadi
      port: 3306
=end