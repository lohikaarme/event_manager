# frozen_string_literal: true

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
      roles: %w[legislatorUpperBody legislatorLowerBody]
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

def track_clean_time(time, array)
  array << Time.parse(time[-5..]).hour
end

def track_clean_days(date, array)
  array << Date.strptime(date, '%m/%d/%y').strftime('%A') # .wday gives numeric
end

def tally(array)
  array.max_by { |el| array.count(el) }
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
contents_lines = CSV.read('event_attendees.csv').length
template_letter = File.read('form_letter.erb')
erb_template = ERB.new File.read('form_letter.erb')
hours_ar = []
days_ar = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  form_letter = erb_template.result(binding)
  save_thank_you_letter(id, form_letter)
  track_clean_time(row[:regdate], hours_ar)
  track_clean_days(row[:regdate], days_ar)
  puts "#{(((id.to_f + 1) / contents_lines) * 100).round(0)}%"
end

puts "Most active hour: #{tally(hours_ar)}"
puts "Most active day: #{tally(days_ar)}"
