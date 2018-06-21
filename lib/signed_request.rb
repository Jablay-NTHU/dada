# frozen_string_literal: true

require 'rbnacl/libsodium'
require 'base64'

require_relative 'securable.rb'

# Parses Json information as needed
class SignedRequest
  extend Securable

  class SignatureVerificationFailed < StandardError; end

  def initialize(config)
    @config = config
  end

  def verify_key
    @verify_key ||= Base64.strict_decode64(@config.VERIFY_KEY)
  end

  def self.generate_keypair
    signing_key = RbNaCl::SigningKey.generate
    verify_key = signing_key.verify_key

    { signing_key: Base64.strict_encode64(signing_key),
      verify_key:  Base64.strict_encode64(verify_key) }
  end

  def parse(signed_json)
    parsed = JSON.parse(signed_json)
    raise unless verify(parsed['signature'], parsed['data'])
    symbolized_hash_keys(parsed['data'])
  rescue StandardError
    raise SignatureVerificationFailed
  end

  private

  def verify(signature64, message)
    signature = Base64.strict_decode64(signature64)
    verifier = RbNaCl::VerifyKey.new(verify_key)
    verifier.verify(signature, message)
  end

  def symbolized_hash_keys(json)
    data = JSON.parse(json)
    Hash[data.map { |k, v| [k.to_sym, v] }]
  end
end
