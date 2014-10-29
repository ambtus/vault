class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :name

      t.timestamps
    end
    create_table :groups_users, id: false do |t|
      t.belongs_to :group
      t.belongs_to :user
    end
  end
end
