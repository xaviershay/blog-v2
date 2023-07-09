require 'date'
require 'zlib'
require 'json'
require 'yaml'

def type_to_ord(type)
  case type
  when 'run' then 1
  when 'workout' then 2
  when 'long_run' then 2
  when "race" then 3
  else 0
  end
end

def compile_run(db_file, out)
  raw = begin
    Zlib::GzipReader.open(db_file) do |f|
      f.read
    end
  rescue Errno::ENOENT
    $stderr.puts "WARNING: No run data found in #{db_file}."
    "{}"
  end

  db = JSON.parse(raw)
  db['activities'] ||= []

  default_yearly_stats = {
    'distance'  => 0,
    'elevation' => 0,
    'duration'  => 0,
  }

  stats = {
    'yearly_stats' => (2010..2023).map {|x| [x, default_yearly_stats.dup] }.to_h,
    'bests'        => [],
    'history'      => {},
  }


  bests = {
    "1 mile"   => 'strava-1477373729',
    '5K'       => 'strava-3260978622',
    '10K'      => 'strava-2193098766',
    'Half'     => 'strava-448924490',
    'Marathon' => 'strava-5719875',
    '50K'      => 'strava-8693546298',
    '100K'     => 'strava-8812330177',
    'Vertical K' => 'strava-9391231065'
  }

  index = {}
  db['activities'].each do |a|
    index[a.fetch('id')] = a
    date = Date.parse(a['date'])
    year = date.strftime('%G').to_i
    week = date.strftime("%-V").to_i
    day = (date.wday - 1) % 7

    stat = stats['yearly_stats'][year] ||= default_yearly_stats
    stat['distance'] += a.fetch('distance') / 1000.0
    stat['elevation'] += a.fetch('elevation') / 1000.0
    stat['duration'] += a.fetch('duration') / 3600.0

    stats['history'][year] ||=
      (1..([Date.new(year, 12, 28), Date.today].min.strftime("%-V").to_i)).map {|x| [x, Array.new(7)] }.to_h
    stats['history'][year][week][day] ||= {}
    stats['history'][year][week][day]['distance'] ||= 0.0
    stats['history'][year][week][day]['distance'] += a.fetch('distance') / 1000.0
    existing = stats['history'][year][week][day]['link'] ||= {}
    x = type_to_ord(a['type'])
    y = type_to_ord(existing['type'])
    if x > y || (x == y && a['duration'] > existing['duration'].to_f)
      existing['href'] = "https://www.strava.com/activities/#{a.fetch('external_id')}"
      existing['title'] = a.fetch('title')
      existing['type'] = a.fetch('type')
      existing['duration'] = a.fetch('duration')
    end
    stats['history'][year][week][day]['debug'] ||= []
    stats['history'][year][week][day]['debug'] << [a.fetch('type'), x, y]
  end

  bests.each do |event, id|
    a = index.fetch(id)
    stats['bests'] << {
      'event' => event,
      'distance' => a.fetch('distance'),
      'duration' => a.fetch('duration'),
      'date' => Date.parse(a.fetch('date')),
      'activity_href' => "https://www.strava.com/activities/#{a.fetch('external_id')}",
      'activity_title' => a.fetch('title')
    }
  end

  File.write(out, stats.to_yaml)
end
