# frozen_string_literal: true

# run pry -r <path/to/this/file>
# require 'rack/test'
# include Rack::Test::Methods

# require_relative '../init'
require './init.rb'
require 'rack/test'

include Rack::Test::Methods

def app
  Dada::Api
end
