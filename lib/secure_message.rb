# frozen_string_literal: true

require 'base64'
require 'rbnacl/libsodium'

# Encrypt and Decrypt from Database
class SecureMessage
  # Generate msg_key for Rake tasks (typically not called at runtime)
  def self.encoded_random_bytes(length)
    bytes = RbNaCl::Random.random_bytes(length)
    Base64.strict_encode64 bytes
  end

  def self.generate_key
    encoded_random_bytes(RbNaCl::SecretBox.key_bytes)
  end

  # Call setup once to pass in config variable with MSG_KEY attribute
  def self.setup(config)
    @config = config
  end

  def self.msg_key
    @msg_key ||= Base64.strict_decode64(@config.MSG_KEY)
  end

  def self.signing_key
    @signing_key ||= Base64.strict_decode64(@config.SIGNING_KEY)
  end

  # Encrypt or else return nil if data is nil
  def self.encrypt(message)
    return nil unless message
    message_json = message.to_json
    simple_box = RbNaCl::SimpleBox.from_secret_key(msg_key)
    ciphertext = simple_box.encrypt(message_json)
    Base64.urlsafe_encode64(ciphertext)
  end

  # Decrypt or else return nil if database value is nil already
  def self.decrypt(ciphertext64)
    return nil unless ciphertext64
    ciphertext = Base64.urlsafe_decode64(ciphertext64)
    simple_box = RbNaCl::SimpleBox.from_secret_key(msg_key)
    message_json = simple_box.decrypt(ciphertext)
    JSON.parse(message_json)
  end

  def self.sign(object)
    message = object.to_json
    signer = RbNaCl::SigningKey.new(signing_key)
    signature_raw = signer.sign(message)
    { data: message,
      signature: Base64.strict_encode64(signature_raw) }
  end
end
