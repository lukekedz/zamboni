require 'nokogiri'
require 'httparty'
require 'json'

puts "anyong!"

page = HTTParty.get('http://games.espn.com/fhl/standings?leagueId=8266&seasonId=2017')

@stats = []
skip   = [2, 12, 18, 19, 20]
columns = ["rk", "team", 2, "g", "a", "pm", "pim", "ppp", "fow", "sog", "hit", "def", 12, "w", "sv", "so", "gaa", "prcnt", 18, 19, 20]

i = 4
while i <= 13
  nth_row = i.to_s
  row = Nokogiri::HTML(page).css('#statsTable tr:nth-child(' + nth_row + ') td')

  team_data = {}
  row.each_with_index do |data, index|
    if !skip.include? index
        team_data[columns[index]] = data.text
    end
  end

  @stats.push team_data
  i += 1
end

@stats.each do |st|
    # puts st.inspect
    # puts
end

# email settings on pi
# http://www.raspberry-projects.com/pi/software_utilities/email/ssmtp-to-send-emails
email = String.new
if !@stats.empty?
	email = 'echo "Scrape successful." | mail -a "From: SPECTRUM UPDATE" -s "Daily Update" psukedz@hotmail.com'
else
	email = 'echo "Problem with scrape." | mail -a "From: SPECTRUM UPDATE" -s "Daily Update" psukedz@hotmail.com'
end
# exec(email)


response = HTTParty.post('http://spectrumhockey.herokuapp.com/site/stats_upload', {
    :body => [ @stats ].to_json,
    :headers => { 'Content-Type' => 'application/json' }
})

puts response.inspect
