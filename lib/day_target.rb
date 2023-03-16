require 'csv'
require 'date'
require 'time'

days_ar= []
days_hash = Hash.new(0)

def track_clean_days(date, array)
  array << Date.strptime(date, "%m/%d/%y").strftime('%A') # .wday gis numeric
end

def tally_days(array, hash)
  array.reduce(hash) do |day, count|
    day[count] += 1
    day
  end
end

puts 'Time targeting initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  track_clean_days(row[:regdate], days_ar) 
end

puts tally_days(days_ar, days_hash)
