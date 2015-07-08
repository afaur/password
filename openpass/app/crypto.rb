class Crypto
  attr_accessor :password, :iv

  def initialize(password, iv)
    @password = password
    @iv = iv
  end

  # binary object
  def key
    data = CocoaSecurity.sha256(password).hexLower
    CocoaSecurityDecoder.new.hex(data)
  end

  # binary object
  def iv
    NSData.from_base64(@iv)
  end

  # base64 binary
  def self.generate_iv
    random = (0...40).map { (32 + rand(95)).chr }.join
    data = CocoaSecurity.sha256(random).hexLower[32, 16]
    [CocoaSecurityDecoder.new.hex(data)].pack('m')
  end

  def encrypt(text)
    CocoaSecurity.send('aesEncrypt:key:iv'.to_sym, text, key, iv).base64
  end

  def decrypt(data)
    CocoaSecurity.send('aesDecryptWithBase64:key:iv'.to_sym, data, key, iv).utf8String
  end

  def self.setup
    iv = 'zAppd54VeAra5GxF60UaIw=='
    Crypto.new('foobar', iv)
  end
end
