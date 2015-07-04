#require 'openssl'
#require 'base64'

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
    Base64.encode64(OpenSSL::Cipher::Cipher.new(ALG).random_iv).chomp
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

