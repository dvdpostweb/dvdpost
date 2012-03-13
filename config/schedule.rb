# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, './log/cron.log'

every :reboot do  
  rake "thinking_sphinx:start"  
end
 
every 1.day, :at => '11:59 am' do 
  rake "thinking_sphinx:reindex"  
end
every 1.day, :at => '01:00 am' do  
  rake "thinking_sphinx:reindex"  
end
every 1.day, :at => '03:00 am' do  
  rake "thinking_sphinx:reindex" ,:environment => 'pre_production' 
end

every 1.day, :at => '2:30 pm' do 
 rake "rake friendly_id:make_slugs MODEL=Director ORDER=directors_id SLUG=1"
end
every 1.day, :at => '2:35 pm' do 
 rake "rake friendly_id:make_slugs MODEL=Actor ORDER=actors_id SLUG=1"
end
every 1.day, :at => '2:40 pm' do 
 rake "rake friendly_id:make_slugs MODEL=ThemesEvent SLUG=1"
end