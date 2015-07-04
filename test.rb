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

class Password
  attr_accessor :uuid, :location, :encryption_version, :iv, :title
  attr_accessor :updatedAt, :createdAt, :createdBy
  attr_accessor :user, :pass
  attr_accessor :master_pass

  def initialize(master_password, data = {})
    @master_pass = master_password
    data.each do |key, value|
      send("#{key}=".to_sym, value)
    end
  end

  def self.all(master_password)
    Dir.glob("*.json").map do |file_name|
      data = JSON.parse(File.read(file_name), symbolize_names: true)
      Password.parse(master_password, data)
    end
  end

  def self.parse(master_password, data)
    wallet = Crypto.new(master_password, data[:iv])
    user_data = JSON.parse(wallet.decrypt(data.delete(:encrypted)), symbolize_names: true)
    Password.new(master_password, user_data.merge(data))
  end

  def save
    File.open(filename, 'w') do |file|
      file.write({
        uuid: uuid,
        location: location,
        encryption_version: encryption_version,
        iv: iv,
        title: title,
        updatedAt: updatedAt,
        createdAt: createdAt,
        createdBy: createdBy,
        encrypted: encrypted,
      }.to_json)
    end
  end

  def filename
    "#{uuid}.json"
  end

  def encrypted
    wallet = Crypto.new(master_pass, iv)
    wallet.encrypt({
      user: user,
      pass: pass
    }.to_json)
  end

  def iv
    unless @iv
      generate_new_iv
    end
    @iv
  end

  def generate_new_iv
    @iv = Crypto.generate_iv
  end

  def user=(val)
    generate_new_iv
    @user = val
  end

  def pass=(val)
    generate_new_iv
    @pass = val
  end

  def uuid
    unless @uuid
      @uuid = SecureRandom.uuid
    end
    @uuid
  end

  def createdAt
    unless @createdAt
      @createdAt = DateTime.now
    end
    @createdAt
  end

  def updatedAt
    @updatedAt = DateTime.now
  end

  def createdBy
    @createdBy || :ruby_desktop_dev
  end

  def encryption_version
    @encryption_version || 1.0
  end
end
=begin
master_password = 'foo'

foo = Password.all(master_password)
binding.pry


pass1 = Password.new(master_password, uuid: 121212, location: 'your moms house', iv: '12221221222', title: 'something')
pass2 = Password.new(master_password, location: 'your moms house', iv: '12221221222', title: 'something')
#pass1.save

pass = Password.new(master_password)
pass.location = 'https://github.com'
pass.user = 'blainesch'
pass.pass = 'foobar'
pass.save
sleep 5
pass.save

# Simple Example
iv = Crypto.generate_iv
wallet = Crypto.new('secret_password', iv)
secret_message = wallet.encrypt('This is a secret message you can only read with my password!')
real_message = wallet.decrypt(secret_message)

puts 'Encrypted:'
puts secret_message

puts 'Decrypted:'
puts real_message
=end
