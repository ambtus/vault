class Efile < ActiveRecord::Base
  belongs_to :owner, :polymorphic => true
  attr_accessor :uploaded_to

  scope :active, -> { where("deleted_by_user_id IS NULL").order("name")  }
  scope :deleted, -> { where("deleted_by_user_id IS NOT NULL").order("updated_at desc") }

  def uploaded_by; User.find_by_id(uploaded_by_user_id); end
  def deleted_by; User.find_by_id(deleted_by_user_id); end

  def remove_file!; File.delete(full_pathname); end
  def remove_tmp!; File.delete(tmp_pathname); end

  def directory; Rails.root.join('files', self.owner.class.name, self.owner.id.to_s); end

  def full_pathname; directory + self.id.to_s; end
  def tmp_pathname; directory + "#{self.id.to_s}.tmp"; end

  def encrypt_file
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.encrypt
    key = cipher.random_key
    iv = cipher.random_iv
    update_attributes(:name => uploaded_to.original_filename, :content_type => uploaded_to.content_type, :key => key, :iv => iv)
    FileUtils::mkdir_p(directory) unless Dir.exists?(directory)
    buf = ""
    File.open(full_pathname, 'wb') do |outf|
      while uploaded_to.read(4096, buf)
        outf << cipher.update(buf)
      end
      outf << cipher.final
    end
  end

  def decrypt_file
    cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
    cipher.decrypt
    cipher.key = key
    cipher.iv = iv
    buf = ""
    File.open(tmp_pathname, "wb") do |outf|
      File.open(full_pathname, "rb") do |inf|
        while inf.read(4096, buf)
          outf << cipher.update(buf)
        end
        outf << cipher.final
      end
    end
  end

end
