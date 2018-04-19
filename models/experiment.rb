# frozen_string_literal: true

require 'json'
require 'base64'
require 'rbnacl/libsodium'

module Experima
  # Holds a full secret document
  class Experiment
    STORE_DIR = 'db/'

    # Create a new experiment by passing in hash of data
    def initialize(new_file)
      @id          = new_file['id'] || new_id
      @researcher  = new_file['researcher']
      @name        = new_file['name']
      @description = new_file['description']
      @content     = encode_content(new_file['content'])
    end

    attr_reader :id, :researcher, :name, :description

    def content
      decode_content(@content)
    end

    def save
      File.open(STORE_DIR + id + '.txt', 'w') do |file|
        file.write(to_json)
      end

      true
    rescue StandardError
      false
    end

    # note: this is not the preferred format for JSON objects
    # see: http://jsonapi.org
    def to_json(options = {})
      JSON({ type: 'document',
             id: @id,
             researcher: @researcher,
             name: @name,
             description: @description,
             content: content }, options)
    end

    def self.setup
      Dir.mkdir(STORE_DIR) unless Dir.exist? STORE_DIR
    end

    def self.find(find_id)
      document_file = File.read(STORE_DIR + find_id + '.txt')
      Document.new JSON.parse(document_file)
    end

    def self.all
      Dir.glob(STORE_DIR + '*.txt').map do |filename|
        filename.match(/#{Regexp.quote(STORE_DIR)}(.*)\.txt/)[1]
      end
    end

    private

    def new_id
      timestamp = Time.now.to_f.to_s
      Base64.urlsafe_encode64(RbNaCl::Hash.sha256(timestamp))[0..9]
    end

    def encode_content(content)
      Base64.strict_encode64(content)
    end

    def decode_content(encoded_content)
      Base64.strict_decode64(encoded_content)
    end
  end
end
