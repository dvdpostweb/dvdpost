#############################################################
#	Application
#############################################################

set :application, "dvdpostapp"
set :deploy_to, "/home/webapps/dvdpostapp/staging"

#############################################################
#	Settings
#############################################################

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "staging" 

#############################################################
#	Servers
#############################################################

set :user, "dvdpostapp"
set :domain, "staging.dvdpost.be"
set :port, 22012
server domain, :app, :web
role :db, domain, :primary => true

#############################################################
#	Git
#############################################################

set :scm, :git
set :branch, "master"
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
    staging:
      adapter: mysql
      encoding: utf8
      database: dvdpost_test
      username: test_devuser
      password: 1nterD3nt
      host: 192.168.100.204
      port: 3306
      slave01:
        adapter: mysql
        encoding: utf8
        database: dvdpost_test
        username: test_devuser
        password: 1nterD3nt
        host: 192.168.100.14
        port: 3306
      slave02:
        adapter: mysql
        encoding: utf8
        database: dvdpost_test
        username: test_devuser
        password: 1nterD3nt
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
   config.cache_store = :file_store, RAILS_ROOT + "/tmp/cache"

   # Don't care if the mailer can't send
   config.action_mailer.raise_delivery_errors = false
   ENV['APP'] = "1"
    EOF
   put env_config, "#{current_path}/config/environments/staging.rb"
  end
end
before 'deploy:symlink', 'deploy:stop_ts'
after 'deploy:symlink', 'deploy:update_ts'
