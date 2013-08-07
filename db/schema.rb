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

ActiveRecord::Schema.define(:version => 20130724231711) do

  create_table "appearances", :force => true do |t|
    t.string   "character_display_name"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.integer  "character_role_id",      :null => false
    t.integer  "tournament_id",          :null => false
    t.string   "character_avatar"
  end

  add_index "appearances", ["character_role_id"], :name => "index_appearances_on_character_role_id"
  add_index "appearances", ["tournament_id"], :name => "index_appearances_on_tournament_id"

  create_table "character_roles", :force => true do |t|
    t.string   "role_type",    :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "character_id", :null => false
    t.integer  "series_id",    :null => false
  end

  add_index "character_roles", ["character_id"], :name => "index_character_roles_on_character_id"
  add_index "character_roles", ["series_id"], :name => "index_character_roles_on_series_id"

  create_table "characters", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "given_name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "main_series_id", :null => false
    t.string   "slug",           :null => false
    t.string   "avatar"
  end

  add_index "characters", ["main_series_id"], :name => "index_characters_on_main_series_id"
  add_index "characters", ["slug"], :name => "index_characters_on_slug", :unique => true

  create_table "friendly_id_slugs", :force => true do |t|
    t.string   "slug",                         :null => false
    t.integer  "sluggable_id",                 :null => false
    t.string   "sluggable_type", :limit => 40
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type"], :name => "index_friendly_id_slugs_on_slug_and_sluggable_type", :unique => true
  add_index "friendly_id_slugs", ["sluggable_id"], :name => "index_friendly_id_slugs_on_sluggable_id"
  add_index "friendly_id_slugs", ["sluggable_type"], :name => "index_friendly_id_slugs_on_sluggable_type"

  create_table "match_entries", :force => true do |t|
    t.integer  "position",          :null => false
    t.integer  "number_of_votes"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "match_id",          :null => false
    t.integer  "previous_match_id"
    t.integer  "appearance_id"
    t.boolean  "is_finished"
    t.boolean  "is_winner"
    t.float    "vote_share"
    t.string   "character_name"
  end

  add_index "match_entries", ["appearance_id"], :name => "index_match_entries_on_appearance_id"
  add_index "match_entries", ["match_id"], :name => "index_match_entries_on_match_id"
  add_index "match_entries", ["previous_match_id"], :name => "index_match_entries_on_previous_match_id"

  create_table "matches", :force => true do |t|
    t.string   "group",           :limit => 1
    t.string   "stage",                        :null => false
    t.integer  "match_number",    :limit => 2
    t.date     "date",                         :null => false
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.integer  "tournament_id",                :null => false
    t.boolean  "is_finished"
    t.integer  "number_of_votes"
    t.boolean  "is_draw"
    t.string   "vote_graph"
  end

  add_index "matches", ["tournament_id"], :name => "index_matches_on_tournament_id"

  create_table "series", :force => true do |t|
    t.string   "name",                       :null => false
    t.string   "color_code",    :limit => 6
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.string   "slug",                       :null => false
    t.string   "sortable_name",              :null => false
  end

  add_index "series", ["slug"], :name => "index_series_on_slug", :unique => true

  create_table "tournaments", :force => true do |t|
    t.string   "year",         :limit => 4, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.text     "group_stages",              :null => false
    t.text     "final_stages",              :null => false
  end

  create_table "voice_actor_roles", :force => true do |t|
    t.boolean  "has_no_voice_actor", :default => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
    t.integer  "voice_actor_id"
    t.integer  "appearance_id",                         :null => false
  end

  add_index "voice_actor_roles", ["appearance_id"], :name => "index_voice_actor_roles_on_appearance_id"
  add_index "voice_actor_roles", ["voice_actor_id"], :name => "index_voice_actor_roles_on_voice_actor_id"

  create_table "voice_actors", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "slug",       :null => false
  end

  add_index "voice_actors", ["slug"], :name => "index_voice_actors_on_slug", :unique => true

end
