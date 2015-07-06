=begin
aes256 = CocoaSecurity.aesEncrypt("kelp", {
  hexKey:"280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9",
  hexIv:"CC0A69779E15780ADAE46C45EB451A23"
})
puts aes256.base64

aes256Decrypt = CocoaSecurity.aesDecryptWithBase64("WQYg5qvcGyCBY3IF0hPsoQ==", {
  hexKey:"280f8bb8c43d532f389ef0e2a5321220b0782b065205dcdfcb8d8f02ed5115b9",
  hexIv:"CC0A69779E15780ADAE46C45EB451A23"
})
aes256Decrypt.utf8String
=end
class Crypto
  attr_accessor :password, :iv

  def initialize(password, iv)
    @password = password
    @iv = iv
  end

  def key
    CocoaSecurity.sha256(password).hexLower
  end

  def self.generate_iv
    CocoaSecurity.sha256(NSDate.date.to_s).hexLower[32, 16]
  end

  def encrypt(text)
    begin
      CocoaSecurity.send('aesEncrypt:hexKey:hexIv'.to_sym, text, key, iv)
    rescue NSException => error
      error.methods
    end
  end

  def decrypt(data)
    CocoaSecurity.send('aesDecryptWithBase64:hexKey:hexIv'.to_sym, data, key, iv).utf8String
  end

  def self.setup
    iv = 'CC0A69779E15780ADAE46C45EB451A23'
    Crypto.new('foobar', iv)
  end
end
