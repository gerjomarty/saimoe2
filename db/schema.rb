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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120409160038) do

  create_table "appearances", :force => true do |t|
    t.string   "character_display_name"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "character_role_id",      :null => false
    t.integer  "tournament_id",          :null => false
  end

  create_table "character_roles", :force => true do |t|
    t.string   "role_type",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "character_id", :null => false
    t.integer  "series_id",    :null => false
  end

  create_table "characters", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "given_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "main_series_id", :null => false
  end

  create_table "match_entries", :force => true do |t|
    t.integer  "position",          :null => false
    t.integer  "number_of_votes"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "match_id",          :null => false
    t.integer  "previous_match_id"
    t.integer  "appearance_id"
  end

  create_table "matches", :force => true do |t|
    t.string   "group",         :limit => 1
    t.string   "stage",                      :null => false
    t.integer  "match_number",  :limit => 2
    t.date     "date",                       :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "tournament_id",              :null => false
  end

  create_table "series", :force => true do |t|
    t.string   "name",                    :null => false
    t.string   "color_code", :limit => 6
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "tournaments", :force => true do |t|
    t.string   "year",       :limit => 4, :null => false
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  create_table "voice_actor_roles", :force => true do |t|
    t.boolean  "has_no_voice_actor", :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "voice_actor_id"
    t.integer  "appearance_id",                         :null => false
  end

  create_table "voice_actors", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

end
