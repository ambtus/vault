class CreateEfiles < ActiveRecord::Migration
  def change
    create_table :efiles do |t|
      t.string :name
      t.string :content_type
      t.binary :key, :limit => 256.bytes
      t.binary :iv, :limit => 256.bytes
      t.references :owner, polymorphic: true
      t.integer :uploaded_by_user_id
      t.integer :deleted_by_user_id

      t.timestamps
    end
  end
end
