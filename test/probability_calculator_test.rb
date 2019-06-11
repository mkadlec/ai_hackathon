require 'minitest/autorun'
require '../models/probability_calculator.rb'

ACCEPTABLE_THRESHOLD = 20

describe ProbabilityCalculator do
  describe 'Marriage Certificate' do
    it 'it returns true for valid certificate data' do
      probability_calculator = ProbabilityCalculator.new(payload_hash(0.4515, 0.0191), ACCEPTABLE_THRESHOLD)
      assert_equal probability_calculator.valid_certificate?(:birthCertificate), true
    end
    it 'returns false for invalid certificate data' do
      probability_calculator = ProbabilityCalculator.new(payload_hash(0.1000, 0.0500), ACCEPTABLE_THRESHOLD)
      assert_equal probability_calculator.valid_certificate?(:birthCertificate), false
    end
  end

  def payload_hash(birth_probability, marriage_probability)
    [
        {
          "classification": {
            "score": birth_probability
          },
          "displayName": "birthCertificate"
        },
        {
          "classification": {
            "score": marriage_probability
          },
          "displayName": "marriage"
        }
    ]
  end
end
