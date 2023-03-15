require 'csv'
require 'date'
require 'time'

hours_ar= []
hours_hash = Hash.new(0)

def track_clean_time(time, array)
  array << Time.parse(time[-5..]).hour
end

def tally_time(array, hash)
  array.reduce(hash) do |hour, count|
    hour[count] += 1
    hour
  end
end

puts 'Time targeting initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  track_clean_time(row[:regdate], hours_ar)
end

puts tally_time(hours_ar, hours_hash)
