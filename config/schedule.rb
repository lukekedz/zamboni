# http://github.com/javan/whenever
# https://github.com/mojombo/chronic

set :chronic_options, :hours24 => true

every 1.day, :at => '06:15' do
  rake "scrape:the_ice"
end
