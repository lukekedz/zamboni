require 'logger'
require 'nokogiri'
require 'httparty'
require 'json'

require_relative 'prettify_log_output'

stamp     = Time.new.strftime('%Y%m%d%H%M')
log       = Logger.new("./logger/log_#{stamp}.txt", 10, 1024000)
log.level = Logger::INFO
output    = PrettifyLogOutput.new

log.info output.start
log.info output.new_line

page = HTTParty.get('http://games.espn.com/fhl/standings?leagueId=8266&seasonId=2018')
log.info page
log.info output.new_line

@stats = []
skip   = [2, 11, 17, 18, 19, 20]
columns = ["rk", "team", 2, "g", "a", "pim", "ppp", "fow", "sog", "hit", "def", 11, "w", "sv", "so", "gaa", "prcnt", 17, 18, 19, 20]

i = 4
while i <= 15
  nth_row = i.to_s
  row = Nokogiri::HTML(page).css('#statsTable tr:nth-child(' + nth_row + ') td')
  log.info "ROW"
  log.info row
  log.info output.new_line

  team_data = {}
  row.each_with_index do |data, index|
    if !skip.include? index
        log.info "INDEX: " + index.to_s
        log.info "DATA: #{columns[index]}"
        log.info data.text
        log.info output.new_line

        team_data[columns[index]] = data.text
    end
  end

  @stats.push team_data

  log.info output.new_line

  i += 1
end

log.info output.new_line
log.info output.new_line

@stats.each do |st|
  log.info st.inspect
  log.info output.new_line
end

response = HTTParty.post('http://spectrumhockey.herokuapp.com/site/stats_upload', {
    :body => [ @stats ].to_json,
    :headers => { 'Content-Type' => 'application/json' },
    # :body => { :secret => ARGV[0] }
})

log.info response.inspect
log.info output.new_line

system "echo 'Here is your daily standings & stat scrape.' | mail -s 'Raspi: SPECTRUM STAT SCRAPE' lukekedziora@gmail.com -A /home/pi/Desktop/zamboni/logger/log_#{stamp}.txt"
