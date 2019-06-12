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
        parsed_text = parse_text(ret_val['responses'])
        return false unless parsed_text

        @keywords.each do |keyword|
          if parsed_text.include? keyword
            puts "Found by the #{keyword} keyword."
            return true
          end
        end

        false
      end

      private

      def parse_text(responses)
        response = responses.first
        return nil unless !!response['textAnnotations']
        annotations = response['textAnnotations'].first
        annotations['description']
      end

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
