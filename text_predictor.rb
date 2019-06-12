require "google/cloud/vision"
require 'open3'
require 'base64'
require 'json'


def payload_hash(file_name)
  file_name = "/Users/MKadlec/Documents/#{file_name}"

  data = Base64.encode64(File.read(file_name)).gsub("\n", '')

  payload_hash = {

      "requests": [
          {
              "features": [
                  {
                      "maxResults": 5,
                      "type": "LABEL_DETECTION"
                  },
                  {
                      "maxResults": 5,
                      "type": "DOCUMENT_TEXT_DETECTION"
                  }
              ],
              "image": {
                  "content": data
              },
              "imageContext": {
                  "cropHintsParams": {
                      "aspectRatios": [
                          0.8,
                          1,
                          1.2
                      ]
                  }
              }
          }
      ]
  }
end

def access_token
  stdout, stderr, status = Open3.capture3("gcloud auth print-access-token")
  stdout.chop!
end

File.open("request.json", "w") do |f|
  f.write(payload_hash('CaliBirthCertificate.jpg').to_json)
end

curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
curl_command +=  " https://vision.googleapis.com/v1/images:annotate -d @request.json"

stdout, stderr, status = Open3.capture3(curl_command)

puts stdout

ret_val = JSON.parse(stdout)

abort('Cannot classify this image.') if ret_val == {}

flower_type = ret_val['payload'][0]['displayName'].to_s
certainty = (ret_val['payload'][0]['classification']['score'] * 100).round(2)

puts "This is classified as #{flower_type} with #{certainty}% certainty."

