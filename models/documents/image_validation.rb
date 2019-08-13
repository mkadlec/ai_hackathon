require 'open3'
require 'base64'
require 'json'
require 'rest-client'
require './models/probability_calculator.rb'

module AiHackathon
  module Documents
    class ImageValidation

      PAYLOAD_FILE = 'request.json'
      ACCEPTABLE_THRESHOLD = 5

      def initialize(data, document_type)
        @data = data
        @document_type = document_type
        create_payload_file
      end

      def validate
        curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
        curl_command += " https://automl.googleapis.com/v1beta1/projects/plansourceml/locations/us-central1/models/ICN6473529023586817442:predict -d @request.json"

        stdout, stderr, status = Open3.capture3(curl_command)

        ret_val = JSON.parse(stdout)
        payload = ret_val['payload']

        abort('Cannot classify this image.') if ret_val == {}

        unless payload.is_a?(Array)
          puts 'Error processing data'
          return
        end

        probability_calculator = ProbabilityCalculator.new(payload, ACCEPTABLE_THRESHOLD)

        probability_calculator.valid_certificate?(@document_type)
      end

      private

      def payload_hash
        hash = {
            payload: {
                image: {
                    imageBytes: @data
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

      def create_payload_file
        File.open(PAYLOAD_FILE, 'w') do |f|
          f.write(payload_hash.to_json)
        end
      end
    end
  end
end
