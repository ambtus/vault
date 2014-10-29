class Group < ActiveRecord::Base
  validates_presence_of :name
  has_and_belongs_to_many :users
  has_many :efiles, :as => :owner
  delegate :active, :deleted, to: :efiles, prefix: true
  delegate :active, to: :users, prefix: true

  before_destroy :destroy_files

  def destroy_files; FileUtils::rm_rf(directory); end
  def directory; Rails.root.join('files', self.class.name, self.id.to_s); end


  scope :by_name, -> { order("name")  }

end
