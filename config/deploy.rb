set :stages, %w(staging pre_production production)
set :default_stage, "staging"
require 'capistrano/ext/multistage'

#Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'hoptoad_notifier-*')].each do |vendored_notifier|
#  $: << File.join(vendored_notifier, 'lib')
#end

#require 'hoptoad_notifier/capistrano'

require 'bundler/capistrano'


after 'deploy:create_symlink' do
  run "ln -nfs #{deploy_to}/shared/uploaded/partner_logos #{deploy_to}/#{current_dir}/public/images/logo"
  run "ln -nfs #{deploy_to}/shared/uploaded/chronicles #{deploy_to}/#{current_dir}/public/images/chronicles/covers"
  run "ln -nfs #{deploy_to}/shared/uploaded/news #{deploy_to}/#{current_dir}/public/images/news_covers"
  run "ln -nfs #{deploy_to}/shared/uploaded/news_thumbs #{deploy_to}/#{current_dir}/public/images/news_thumbs"
end

# Thinking Sphinx
namespace :thinking_sphinx do
  task :configure, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:configure RAILS_ENV=#{rails_env}"
  end
  task :index, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:index RAILS_ENV=#{rails_env}"
  end
  task :reindex, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:reindex RAILS_ENV=#{rails_env}"
  end
  task :start, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
  end
  task :stop, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:stop RAILS_ENV=#{rails_env}"
  end
  task :restart, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:restart RAILS_ENV=#{rails_env}"
  end
  task :rebuild, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:rebuild RAILS_ENV=#{rails_env}"
  end
end

# Thinking Sphinx typing shortcuts
namespace :ts do
  task :conf, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:configure RAILS_ENV=#{rails_env}"
  end
  task :in, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:index RAILS_ENV=#{rails_env}"
  end
  task :rein, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:reindex RAILS_ENV=#{rails_env}"
  end
  task :start, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:start RAILS_ENV=#{rails_env}"
  end
  task :stop, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:stop RAILS_ENV=#{rails_env}"
  end
  task :restart, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:restart RAILS_ENV=#{rails_env}"
  end
  task :rebuild, :roles => [:app] do
    run "cd #{current_path};bundle exec rake thinking_sphinx:rebuild RAILS_ENV=#{rails_env}"
  end
end

namespace :deploy do
  task :stop_ts do
    # Stop Thinking Sphinx before the update so it finds its configuration file.
    thinking_sphinx.stop rescue nil # Don't fail if it's not running, though.
  end

  desc "Link up Sphinx's indexes."
  task :symlink_sphinx_indexes, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/sphinx #{current_path}/db/sphinx"
    run "ln -nfs /data/geoip/GeoIP.dat #{current_path}/GeoIP.dat"

  end

  task :update_ts do
    symlink_sphinx_indexes
    thinking_sphinx.configure
    thinking_sphinx.start
  end
end

Dir[File.join(File.dirname(__FILE__), '..', 'vendor', 'gems', 'airbrake-*')].each do |vendored_notifier|
  $: << File.join(vendored_notifier, 'lib')
end

require 'airbrake/capistrano'
