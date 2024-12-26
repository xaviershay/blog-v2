require 'json'
require 'pp'
require 'date'

cutoff = Date.new(2024,1,1)

puts cutoff
data = JSON.parse(File.read('tmp/gratitudes-data-2024.json')).fetch('entries')
  # Entry data is double JSON encoded
  .map {|x| JSON.parse(x) }
  .select {|x| Date.parse(x.fetch('date')) >= cutoff }

data.each do |x|
  puts x.fetch('date')
  puts x.fetch('entry')
  puts
end

# pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /jodie/i  } }.length
# pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /jodie/i && y =~ /crossword/i } }.length
# pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /crossword/i } }.length
# pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /pinball/i || y =~ /godzilla/i } }.length
