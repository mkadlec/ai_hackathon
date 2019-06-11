##############################################
# This will hold all payload logic
##############################################
class Payload

  attr_reader :raw_payload

  def initialize(raw_payload)
    @raw_payload = symbolize(raw_payload)
  end

  def sorted
    raw_payload.sort_by { |hsh| hsh[:classification][:score] }.reverse!
  end

  private

  def symbolize(obj)
    return obj.reduce({}) do |memo, (k, v)|
      memo.tap { |m| m[k.to_sym] = symbolize(v) }
    end if obj.is_a? Hash

    return obj.reduce([]) do |memo, v|
      memo << symbolize(v); memo
    end if obj.is_a? Array

    obj
  end

end
