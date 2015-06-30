require 'openssl'
require 'base64'
require 'json'
require 'date'

class Crypto
  attr_accessor :password, :iv
  ALG = 'AES-256-CBC'

  def initialize(password, iv)
    @password = password
    @iv = iv
  end

  def key
    digest = Digest::SHA256.new
    digest.update(password)
    digest.digest
  end

  def self.generate_iv
    Base64.encode64(OpenSSL::Cipher::Cipher.new(ALG).random_iv)
  end

  def cipher(type)
    aes = OpenSSL::Cipher::Cipher.new(ALG)
    aes.send(type)
    aes.key = key
    aes.iv = Base64.decode64(iv)
    aes
  end

  def encrypt(text)
    aes = cipher(:encrypt)
    Base64.encode64(aes.update(text) + aes.final)
  end

  def decrypt(data)
    aes = cipher(:decrypt)
    aes.update(Base64.decode64(data)) + aes.final
  end
end

class Source
  def read

  end

  def write(model)
    data = model.to_obj
    data[:createdAt] ||= DateTime.new
    data[:updatedAt] ||= DateTime.new
    data[:createdBy] ||= 'DesktopRuby'
    File.open(data[:id], 'w') { |file|
      file.write(data.to_json)
    }
  end
end

class Password
  attr_accessor :locationKey, :iv, :title, :location, :user, :pass
  attr_accessor :createdAt, :updatedAt, :createdBy

  # Model?
  def self.all
    Source.all
  end

  def save
    Source.write(self)
  end
  # /Model?

  def to_obj
    instance_variables.inject({}) do |memo, el|
      key = el.to_s[1..-1].to_sym
      memo[key] = send(key)
      memo
    end
  end

  def filename
  end
end

# Simple Example
iv = Crypto.generate_iv
wallet = Crypto.new('secret_password', iv)
secret_message = wallet.encrypt('This is a secret message you can only read with my password!')
real_message = wallet.decrypt(secret_message)

puts 'Encrypted:'
puts secret_message

puts 'Decrypted:'
puts real_message

# Saving and opening from a file
data = {
  iv: iv,
  message: secret_message
}
puts data.to_json
