# frozen_string_literal: true

# Parses Json information as needed
class JsonRequestBody
  def self.parse_symbolize(json_str)
    parsed = JSON.parse(json_str)
    Hash[parsed.map { |k, v| [k.to_sym, v] }]
  end
end