# http://github.com/javan/whenever
# https://github.com/mojombo/chronic

set :chronic_options, :hours24 => true

every 1.day, :at => '09:55' do
  rake "scrape:the_ice"
end
