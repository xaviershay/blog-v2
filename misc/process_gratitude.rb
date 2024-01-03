require 'json'
require 'pp'

data = JSON.parse(File.read('tmp/gratitudes-data.json'))
  # Entry data is double JSON encoded
  .map {|x| JSON.parse(x[1]) }

pp data.length

pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /jodie/i  } }.length
pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /jodie/i && y =~ /crossword/i } }.length
pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /crossword/i } }.length
pp data.select {|x| x['entry'] }.filter {|x| x['entry'].lines.any? {|y| y =~ /pinball/i || y =~ /godzilla/i } }.length
