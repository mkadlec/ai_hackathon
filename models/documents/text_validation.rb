require 'open3'
require 'base64'
require 'json'
require 'rest-client'
require './models/probability_calculator.rb'


module AiHackathon
  module Documents
    class TextValidation
      PAYLOAD_FILE = 'request.json'
      ACCEPTABLE_THRESHOLD = 5

      def initialize(data, keywords)
        @data = data
        @keywords = keywords
        create_payload_file
      end

      def validate
        curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
        curl_command +=  " https://vision.googleapis.com/v1/images:annotate -d @request.json"

        stdout, stderr, status = Open3.capture3(curl_command)

        ret_val = JSON.parse(stdout)

        response = ret_val['responses'].first
        return false unless !!response['textAnnotations']
        annotations = response['textAnnotations'].first
        parsed_text = annotations['description']

        @keywords.each do |keyword|
          puts "Checking #{keyword}"
          return true if parsed_text.include? keyword
        end

        false
      end

      private

      def payload_hash
        hash = {

            "requests": [
                {
                    "features": [
                        {
                            "maxResults": 3,
                            "type": "DOCUMENT_TEXT_DETECTION"
                        }
                    ],
                    "image": {
                        "content": @data
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

      def create_payload_file
        File.open(PAYLOAD_FILE, 'w') do |f|
          f.write(payload_hash.to_json)
        end
      end
    end
  end
end
