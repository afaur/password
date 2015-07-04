#require 'json'
#require 'date'
#require 'securerandom'

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
    Dir.glob("resources/*.json").map do |file_name|
      data = BW::JSON.parse(File.read(file_name))  #, symbolize_names: true)
      Password.parse(master_password, data)
    end
  end

  def self.parse(master_password, data)
    wallet = ::Crypto.new(master_password, data['iv'])
    user_data = BW::JSON.parse( wallet.decrypt( data.delete('encrypted') ) )  #, symbolize_names: true)
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

