require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'
require 'time'


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'
  
  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
    
  rescue StandardError
    'You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials'
  end
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  
  filename = "output/thanks_#{id}.html"
  
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def largest_hash_key(hash)
  hash.max_by{ |_, v| v}
end

def track_clean_time(time, array)
  array << Time.parse(time[-5..]).hour
end

def track_clean_days(date, array)
  array << Date.strptime(date, "%m/%d/%y").strftime('%A') # .wday gis numeric
end

def tally(array, hash)
  array.reduce(hash) do |hour, count|
    hour[count] += 1
    hour
  end
  largest_hash_key(hash)
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

template_letter = File.read('form_letter.erb')
erb_template = ERB.new File.read('form_letter.erb')
hours_ar= []
hours_hash = Hash.new(0)
days_ar= []
days_hash = Hash.new(0)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
  track_clean_time(row[:regdate], hours_ar)
  track_clean_days(row[:regdate], days_ar) 
end

puts "Most active hour: #{tally(hours_ar, hours_hash)[0]}"
puts "Most active day: #{tally(days_ar, days_hash)[0]}"
