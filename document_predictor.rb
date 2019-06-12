require './models/documents/validator.rb'


def retrieve_data(file_name)
  #file_name = !!ARGV && ARGV.length > 0 ? ARGV[0] : 'colorado_marriage.jpg'
  file_path = "/Users/MKadlec/Documents/ai/#{file_name}"

  Base64.encode64(File.read(file_path)).gsub("\n", '')
end

Dir.foreach('/Users/MKadlec/Documents/ai') do |file_item|
  next if file_item == '.'
  next if file_item == '..'
  puts 'Processing ' + file_item.to_s + '...'
  AiHackathon::Documents::Validator.new(retrieve_data(file_item.to_s), :marriage).validate
end



