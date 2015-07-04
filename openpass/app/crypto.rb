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
  ALG = 'AES-256-CBC'

  def initialize(password, iv)
    @password = password
    @iv = iv
  end

  def key
    CocoaSecurity.sha384(password).hexLower[0, 32]
  end

  def self.generate_iv
    CocoaSecurity.sha384(NSDate.date.to_s).hexLower[32, 16]
  end

  def encrypt(text)
    aes256 = CocoaSecurity.send('aesEncrypt:key'.to_sym, text, {
      hexKey: key,
      hexIv: iv
    })
    aes256.base64
  end

  def decrypt(data)
    aes256Decrypt = CocoaSecurity.send('aesDecryptWithBase64:key'.to_sym, data, {
      hexKey: key,
      hexIv: iv
    })
    aes256Decrypt.utf8String
  end
end
