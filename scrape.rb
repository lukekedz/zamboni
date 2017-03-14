require 'nokogiri'
require 'httparty'
require 'pg'

puts "anyong!!!"

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
    puts st.inspect
    puts
end

response = HTTParty.post('http://localhost:3000/site/stats_upload', {
    :body => [ @stats ].to_json,
    :headers => { 'Content-Type' => 'application/json' }
})

puts response.inspect
