# frozen_string_literal: true

# run pry -r <path/to/this/file>
require 'rack/test'
include Rack::Test::Methods

require_relative '../init'
# require_relative '../app'
# require_relative '../models/project'
# require_relative '../models/request'
# require_relative '../models/response'

def app
  Dada::Api
end
