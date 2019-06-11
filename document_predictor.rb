require "google/cloud/vision"
require 'open3'
require 'base64'
require 'json'
require 'rest-client'
require './models/probability_calculator.rb'

ACCEPTABLE_THRESHOLD = 10

def payload_hash
  file_name = !!ARGV && ARGV.length > 0 ? ARGV[0] : 'colorado_marriage.jpg'
  file_name = "/Users/MKadlec/Documents/#{file_name}"

  data = Base64.encode64(File.read(file_name)).gsub("\n", '')

  hash = {
    payload: {
      image: {
        imageBytes: data
      }
    },
    params: {
      score_threshold: '0.0'
    }
  }
end

def access_token
  stdout, stderr, status = Open3.capture3("gcloud auth print-access-token")
  stdout.chop!
end

File.open('request.json', 'w') do |f|
  f.write(payload_hash.to_json)
end

curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
curl_command +=  " https://automl.googleapis.com/v1beta1/projects/plansource-document-audit/locations/us-central1/models/ICN3696112647569160451:predict -d @request.json"

# url = 'https://automl.googleapis.com/v1beta1/projects/plansource-document-audit/locations/us-central1/models/ICN3696112647569160451:predict'
# headers = {content_type: :json,  Authorization: "Bearer #{access_token}" }
# rest_call = RestClient.post(url, payload_hash, headers)
# puts rest_call.inspect

stdout, stderr, status = Open3.capture3(curl_command)

puts stdout

ret_val = JSON.parse(stdout)
payload = ret_val['payload']

abort('Cannot classify this image.') if ret_val == {}

doc_type = payload[0]['displayName'].to_s
certainty = (payload[0]['classification']['score'] * 100).round(2)

puts "This is classified as #{doc_type} with #{certainty}% certainty."

probability_calculator = ProbabilityCalculator.new(payload, ACCEPTABLE_THRESHOLD)
puts "Valid birth certificate? #{probability_calculator.valid_certificate?(:birthCertificate)}."
puts "Valid marriage license? #{probability_calculator.valid_certificate?(:marriage)}."
