class User < ActiveRecord::Base
  validates_presence_of :name, :email
  validates_uniqueness_of :name, :email
  has_and_belongs_to_many :groups
  has_many :efiles, :as => :owner
  delegate :active, :deleted, to: :efiles, prefix: true
  scope :active, -> { where("suspended IS NULL").order("name")  }
  scope :inactive, -> { where("suspended IS NOT NULL").order("name")  }

  def efiles_uploaded; Efile.where("uploaded_by_user_id IS #{id}"); end
  def efiles_deleted; Efile.where("deleted_by_user_id IS #{id}"); end

  before_destroy :destroy_files

  def destroy_files; FileUtils::rm_rf(directory); end
  def directory; Rails.root.join('files', self.class.name, self.id.to_s); end

  def set_token!; self.update_attribute(:token, SecureRandom.hex); end
  def unset_token!; self.update_attribute(:token, nil); end

end
