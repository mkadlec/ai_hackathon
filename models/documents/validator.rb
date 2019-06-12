require 'open3'
require 'base64'
require 'json'
require 'rest-client'
require './models/probability_calculator.rb'

module AiHackathon
  module Documents
    class Validator

      PAYLOAD_FILE = 'request.json'
      ACCEPTABLE_THRESHOLD = 10

      def initialize(data, document_type)
        @data = data
        @document_type = document_type
        create_payload_file
      end

      def validate
        curl_command = 'curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %{access_token}"' % {access_token: access_token}
        curl_command +=  " https://automl.googleapis.com/v1beta1/projects/plansource-document-audit/locations/us-central1/models/ICN3696112647569160451:predict -d @request.json"

        stdout, stderr, status = Open3.capture3(curl_command)

        puts stdout

        ret_val = JSON.parse(stdout)
        payload = ret_val['payload']

        abort('Cannot classify this image.') if ret_val == {}

        unless payload.is_a?(Array)
          puts 'Error processing data'
          return
        end

        # doc_type = payload[0]['displayName'].to_s
        # certainty = (payload[0]['classification']['score'] * 100).round(2)
        #
        # #puts "This is classified as #{doc_type} with #{certainty}% certainty."

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