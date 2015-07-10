class Base64
  def self.encode64(text)
    [text].pack('m')
  end

  def self.decode64(data)
    data.unpack('m').first
  end
end

class Crypto
  attr_accessor :password, :iv

  def initialize(password, iv)
    @password = password
    @iv = iv
  end

  def key
    data = CocoaSecurity.sha256(password).hexLower
    CocoaSecurityDecoder.new.hex(data)
  end

  def iv
    NSData.from_base64(@iv)
  end

  def self.generate_iv
    data = CocoaSecurity.sha256(random_data).hexLower[32, 16]
    Base64.encode64(CocoaSecurityDecoder.new.hex(data))
  end

  def random_data
    (0...999).map { (32 + rand(95)).chr }.join
  end

  def encrypt(text)
    CocoaSecurity.send('aesEncrypt:key:iv', text, key, iv).base64
  end

  def decrypt(data)
    CocoaSecurity.send('aesDecryptWithBase64:key:iv', data, key, iv).utf8String
  end

  def self.setup
    iv = 'zAppd54VeAra5GxF60UaIw=='
    Crypto.new('foobar', iv)
  end
end
