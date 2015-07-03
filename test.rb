require 'openssl'
require 'base64'
require 'json'
require 'date'
require 'securerandom'
require 'pry'

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

class Password
  attr_accessor :uuid, :location, :encryption_version, :iv, :title
  attr_accessor :updatedAt, :createdAt, :createdBy
  attr_accessor :user, :pass

  def save
    File.open('foo.json', 'w') do |file|
      file.write('{
      uuid: uuid,
      location: location,
      encryption_version: encryption_version,
      iv: iv,
      title: title,
      updatedAt: updatedAt,
      createdAt: createdAt,
      createdBy: createdBy,
      user: user,
      pass: pass
      }')
    end
  end

  def initialize(data)
    data.each do |key, value|
      send("#{key}=".to_sym, value)
    end
  end

  def uuid
    unless @uuid
      @uuid = SecureRandom.uuid
    end
    @uuid
  end

  def createdAt
    unless @createdAt
      @createdAt = DateTime.new
    end
    @createdAt
  end

  def updatedAt
    @updatedAt = DateTime.new
  end

  def createdBy
    @createdBy || :ruby_desktop_dev
  end

  def encryption_version
    @encryption_version || 1.0
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
