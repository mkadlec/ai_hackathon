require './models/documents/validator.rb'

TEST_FILE_DIR = '/Users/MKadlec/Documents/ai'

def retrieve_data(file_name)
  #file_name = !!ARGV && ARGV.length > 0 ? ARGV[0] : 'colorado_marriage.jpg'
  file_path = "/Users/MKadlec/Documents/ai/#{file_name}"

  Base64.encode64(File.read(file_path)).gsub("\n", '')
end

marriage_cert_count = 0

total_file_count = Dir[TEST_FILE_DIR + '/**/*'].length

Dir.foreach(TEST_FILE_DIR) do |file_item|
  next if file_item == '.'
  next if file_item == '..'
  puts "Processing #{file_item.to_s}..."
  result = AiHackathon::Documents::Validator.new(retrieve_data(file_item.to_s), :marriage).validate
  marriage_cert_count += 1 if result
  puts 'Is this a marriage certificate? ' + result.to_s
  puts 'Marriage cert count: ' + marriage_cert_count.to_s
end

puts 'total file count: ' + total_file_count.to_s


