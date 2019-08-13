require './models/documents/image_validation.rb'
require './models/documents/text_validation.rb'

TEST_FILE_DIR = '/Users/MKadlec/Documents/ai'

def retrieve_data(file_name)
  file_path = "#{TEST_FILE_DIR}/#{file_name}"
  Base64.encode64(File.read(file_path)).gsub("\n", '')
end

def move_file(file_name, success)
  folder_name = success ? 'success' : 'fail'
  File.rename("#{TEST_FILE_DIR}/#{file_name}", "#{TEST_FILE_DIR}/#{folder_name}/#{file_name}")
end

def analyze_file_by_document_type(document_type, file_name, keywords)
  file_data = retrieve_data(file_name)
  result = AiHackathon::Documents::ImageValidation.new(file_data, document_type).validate
  found = false
  if result
    found = true
    puts "By image recognition, this was confirmed to be a #{document_type.to_s}"
  else
    puts 'Checking text recognition...'
    text_result = AiHackathon::Documents::TextValidation.new(file_data, keywords).validate
    puts 'Results of text search: ' + text_result.to_s
    found = true if text_result
  end
  found
end

def analyze_documents(document_type, text_locator_keywords)
  certification_count = 0
  Dir.foreach(TEST_FILE_DIR) do |file_item|
    next if file_item.start_with?('.')
    next if file_item == '..'
    file_name = file_item.to_s
    puts "Processing #{file_name}..."

    next unless File.file?("#{TEST_FILE_DIR}/#{file_name}")
    found = analyze_file_by_document_type(document_type, file_name, text_locator_keywords)

    certification_count += 1 if found
    move_file(file_name, found)

    puts 'Certifications found: ' + certification_count.to_s
    sleep(3)
  end
end

document_type = :marriage
total_file_count = Dir[TEST_FILE_DIR + '/**/*'].length
text_locator_keywords = ['Marriage', 'Matrimony', 'License', 'Wedlock', 'Witness']

analyze_documents(document_type, text_locator_keywords)

puts 'Total file count: ' + total_file_count.to_s


