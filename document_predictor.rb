require './models/documents/image_validation.rb'
require './models/documents/text_validation.rb'

TEST_FILE_DIR = '/Users/MKadlec/Documents/ai'

def retrieve_data(file_name)
  file_path = "/Users/MKadlec/Documents/ai/#{file_name}"
  Base64.encode64(File.read(file_path)).gsub("\n", '')
end

def move_file(file_name, success)
  folder_name = success ? 'success' : 'fail'
  File.rename("#{TEST_FILE_DIR}/#{file_name}", "#{TEST_FILE_DIR}/#{folder_name}/#{file_name}")
end

marriage_cert_count = 0

total_file_count = Dir[TEST_FILE_DIR + '/**/*'].length

Dir.foreach(TEST_FILE_DIR) do |file_item|
  next if file_item == '.'
  next if file_item == '..'
  file_name = file_item.to_s
  puts "Processing #{file_name}..."
  found = false
  next unless File.file?("/Users/MKadlec/Documents/ai/#{file_name}")
  file_data = retrieve_data(file_name)
  result = AiHackathon::Documents::ImageValidation.new(file_data, :marriage).validate
  if result
    found = true
    puts 'Based on image recognition, this is a Marriage Certificate. '
  else
    puts 'Checking text recognition...'
    marriage_keywords = ['Marriage', 'Matrimony', 'License', 'Wedlock', 'Witness']
    text_result = AiHackathon::Documents::TextValidation.new(file_data, marriage_keywords).validate
    puts 'Results of text search: ' + text_result.to_s
    found = true if text_result
  end

  marriage_cert_count += 1 if found

  move_file(file_name, found)

  puts 'Marriage cert count: ' + marriage_cert_count.to_s
  sleep(3)
end

puts 'total file count: ' + total_file_count.to_s


