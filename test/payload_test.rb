require 'minitest/autorun'
require '../models/payload.rb'

UNSORTED_PAYLOAD = [
    {
        "classification": {
            "score": 0.3
        },
        "displayName": "abc"
    },
    {
        "classification": {
            "score": 0.4
        },
        "displayName": "def"
    },
    {
        "classification": {
            "score": 0.1
        },
        "displayName": "ghi"
    }
].freeze

describe Payload do
  describe 'Sort' do
    it 'descending' do
      sorted_payload = Payload.new(UNSORTED_PAYLOAD).sorted
      assert_equal sorted_payload[0][:displayName], 'def'
    end
  end
end
