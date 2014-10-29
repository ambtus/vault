# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20141020203534) do

  create_table "efiles", force: true do |t|
    t.string   "name"
    t.string   "content_type"
    t.binary   "key",                 limit: 256
    t.binary   "iv",                  limit: 256
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "uploaded_by_user_id"
    t.integer  "deleted_by_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups_users", id: false, force: true do |t|
    t.integer "group_id"
    t.integer "user_id"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.boolean  "admin"
    t.boolean  "suspended"
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
