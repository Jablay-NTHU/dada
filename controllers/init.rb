# frozen_string_literal: true

require_relative 'app'

Dir.glob("#{File.dirname(__FILE__)}/*.rb").each do |file|
  require file
end
