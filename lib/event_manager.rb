# frozen_string_literal: true

require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

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

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, '0')[0..4]
end

def save_thank_you_letter(id, form_letter)
  Dir.mkdir('output') unless Dir.exist?('output')
  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def clean_phone(phone)
  num = phone.tr('^0-9', '')
  if num.length == 11 && num[0] == '1'
    num[1..10]
  elsif num.length != 10
    nil
  else
    num
  end
end

def largest_key(hash)
  hash.max_by{|_,v| v}[0]
end

puts 'Event Manager Initialized!'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new template_letter
reg_time = Hash.new(0)
reg_date = Hash.new(0)

contents.each do |row|
  id = row[0]
  reg = Time.strptime(row[:regdate], '%m/%d/%y %k:%M')
  reg_time[reg.hour] += 1
  reg_date[Date::DAYNAMES[reg.wday]] += 1
  # name = row[:first_name]
  # phone = clean_phone(row[:homephone])
  # zipcode = clean_zipcode(row[:zipcode])
  # legislators = legislators_by_zipcode(zipcode)
  # form_letter = erb_template.result(binding)
  # save_thank_you_letter(id, form_letter)
  # puts phone
end

puts "Most popular registration day: #{largest_key(reg_date)}"
puts "Most popular registration hour: #{largest_key(reg_time)}"
