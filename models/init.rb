# frozen_string_literal: true

# require_relative './project'
# require_relative './request'
# require_relative './response'

Dir.glob("#{File.dirname(__FILE__)}/**/*.rb").each do |file|
  require file
end
