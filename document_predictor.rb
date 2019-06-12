require './models/documents/validator.rb'
require './models/documents/text_validation.rb'

TEST_FILE_DIR = '/Users/MKadlec/Documents/ai'

def retrieve_data(file_name)
  file_path = "/Users/MKadlec/Documents/ai/#{file_name}"

  Base64.encode64(File.read(file_path)).gsub("\n", '')
end

marriage_cert_count = 0

total_file_count = Dir[TEST_FILE_DIR + '/**/*'].length

Dir.foreach(TEST_FILE_DIR) do |file_item|
  next if file_item == '.'
  next if file_item == '..'
  found = false
  file_name = file_item.to_s
  puts "Processing #{file_name}..."
  next unless File.file?("/Users/MKadlec/Documents/ai/#{file_name}")
  result = AiHackathon::Documents::Validator.new(retrieve_data(file_name), :marriage).validate
  if result
    found = true
    puts 'Is this a marriage certificate? ' + result.to_s
  else
    puts 'Checking text...'
    marriage_keywords = ['Marriage', 'Matrimony', 'License', 'Wedlock', 'Witness']
    text_result = AiHackathon::Documents::TextValidation.new(retrieve_data(file_item.to_s), marriage_keywords).validate
    puts 'Results of text search: ' + text_result.to_s
    found = true if text_result
  end

  if found
    marriage_cert_count += 1
    File.rename("/Users/MKadlec/Documents/ai/#{file_name}", "/Users/MKadlec/Documents/ai/success/#{file_name}")
  else
    File.rename("/Users/MKadlec/Documents/ai/#{file_name}", "/Users/MKadlec/Documents/ai/fail/#{file_name}")
  end

  puts 'Marriage cert count: ' + marriage_cert_count.to_s

  sleep(3)

end

puts 'total file count: ' + total_file_count.to_s


