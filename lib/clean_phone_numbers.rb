require 'csv'

def clean_phone_numbers(phone)
  phone = phone.to_s.tr('^0-9', '')

  phone[0] = '' if phone[0] == '1'

  phone = nil if phone.length != 10

  phone
end

puts 'Clean phone numbers initialized'

contents = CSV.open(
  'event_attendees.csv',
  headers: true,
  header_converters: :symbol
)

contents.each do |row|
  phone = clean_phone_numbers(row[:homephone])

  puts phone
end

# If less than 10 digits, assume that it is a bad number
# If 10 digits, assume that it is good
# If 11 digits and the first number is 1, trim the 1 and use the remaining 10 digits
# If 11 digits and the first number is not 1, then it is a bad number
# If more than 11 digits, assume that it is a bad number