require 'logger'
require 'nokogiri'
require 'httparty'
require 'json'

require_relative 'prettify_log_output'

log       = Logger.new('./logger/scrape.log', 'daily')
log.level = Logger::INFO
output    = PrettifyLogOutput.new

log.info output.start
log.info output.new_line

page = HTTParty.get('http://games.espn.com/fhl/standings?leagueId=8266&seasonId=2018')
log.info page
log.info output.new_line

@stats = []
skip   = [2, 11, 17, 18, 19, 20]
columns = ['rk', 'team', 2, 'g', 'a', 'pim', 'ppp', 'fow', 'sog', 'hit', 'def', 11, 'w', 'sv', 'so', 'gaa', 'prcnt', 17, 18, 19, 20]

i = 4
while i <= 15
  nth_row = i.to_s
  row = Nokogiri::HTML(page).css('#statsTable tr:nth-child(' + nth_row + ') td')
  log.info 'ROW'
  log.info row
  log.info output.new_line

  team_data = {}
  row.each_with_index do |data, index|
    if !skip.include? index
        log.info 'INDEX: ' + index.to_s
        log.info "DATA: #{columns[index]}"
        log.info data.text
        log.info output.new_line

        team_data[columns[index]] = data.text.strip
    end
  end

  @stats.push team_data

  log.info output.new_line

  i += 1
end

log.info output.new_line
log.info output.new_line

@stats.unshift(ARGV[0])

response = HTTParty.post('http://spectrumhockey.herokuapp.com/site/stats_upload', {
    :body => [ @stats ].to_json,
    :headers => { 'Content-Type' => 'application/json'  },
})

log.info response.inspect
log.info output.new_line

email_log       = Logger.new('./logger/email.log', 'daily')
email_log.level = Logger::INFO

email_log.info 'RESPONSE CODE: ' + response.code.to_s
email_log.info 'SCRAPED STATS: '
@stats.each_with_index { |st, index| email_log.info st.inspect if index != 0 }
email_log.info output.new_line

last_twelve = HTTParty.get('http://spectrumhockey.herokuapp.com/site/last_twelve')
email_log.info last_twelve.parsed_response.inspect
email_log.info output.new_line

email_log.info File.read('./logger/scrape.log')
email_log.info output.new_line

if response.code == 200
  system "echo 'Here is your daily standings & stat scrape.' | mail -s 'SPECTRUM: Ice Scraped Successfully' lukekedziora@gmail.com -A /home/pi/Desktop/zamboni/logger/email.log"
else
  system "echo 'ERROR' | mail -s 'SPECTRUM: ZAMBONI BROKEN!' lukekedziora@gmail.com -A /home/pi/Desktop/zamboni/logger/email.log"
end
