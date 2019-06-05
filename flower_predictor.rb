require "google/cloud/vision"
require 'open3'
require 'base64'
require 'json'


def payload_hash
  file_name = !!ARGV && ARGV.length > 0 ? ARGV[0] : 'girl_red_flower.jpg'
  file_name = "/Users/MKadlec/Documents/#{file_name}"

  data = Base64.encode64(File.read(file_name)).gsub("\n", '')

  payload_hash = {
    payload: {
      image: {
        imageBytes: data
      }
    }
  }
end

def access_token
  stdout, stderr, status = Open3.capture3("gcloud auth print-access-token")
  stdout.chop!
end

File.open("request.json", "w") do |f|
   f.write(payload_hash.to_json)
end

curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
curl_command +=  " https://automl.googleapis.com/v1beta1/projects/plansource-document-audit/locations/us-central1/models/ICN5747522772793646385:predict -d @request.json"

stdout, stderr, status = Open3.capture3(curl_command)

ret_val = JSON.parse(stdout)

abort('Cannot classify this immage.') if ret_val == {}

flower_type = ret_val['payload'][0]['displayName'].to_s
certainty = (ret_val['payload'][0]['classification']['score'] * 100).round(2)

puts "This is classified as #{flower_type} with #{certainty}% certainty."
