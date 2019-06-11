require_relative './payload.rb'

##############################################
# This calculator determines if the Document
# is of a certain type
##############################################
class ProbabilityCalculator

  attr_reader :payload, :validity_threshold

  def initialize(payload, validity_threshold)
    @payload = ::Payload.new(payload).sorted
    @validity_threshold = validity_threshold
  end

  def valid_certificate?(certificate_type)
    payload = extract_payload
    return false unless payload
    return true if payload.length == 1

    top_probability_element = payload.first
    second_probability_element = payload[1]
    return false unless top_probability_element[:displayName].to_s == certificate_type.to_s

    top_probability_percent = probability_percent(top_probability_element)
    second_probability_percent = probability_percent(second_probability_element)

    return true if meets_threshold?(top_probability_percent, second_probability_percent)

    false
  end

  private

  def meets_threshold?(top_percent, second_percent)
    return false if second_percent.zero?
    top_percent / second_percent > validity_threshold
  end

  def probability_percent(element)
    element[:classification][:score] * 100
  end

  def extract_payload
    return nil unless payload
    return nil if payload.empty?
    payload
  end

end
