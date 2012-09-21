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

ActiveRecord::Schema.define(:version => 20120921180717) do

  create_table "duration_kinds", :id => false, :force => true do |t|
    t.string   "code",                   :limit => 30,  :null => false
    t.datetime "date_created",                          :null => false
    t.string   "created_by",             :limit => 32,  :null => false
    t.datetime "last_modified",                         :null => false
    t.string   "modified_by",            :limit => 32,  :null => false
    t.integer  "status",                                :null => false
    t.string   "display_label",          :limit => 100, :null => false
    t.string   "abbr_label",             :limit => 4,   :null => false
    t.integer  "production_category_id",                :null => false
  end

  add_index "duration_kinds", ["abbr_label"], :name => "duration_kinds_abbr_label_unique", :unique => true
  add_index "duration_kinds", ["display_label"], :name => "duration_kinds_display_label_unique", :unique => true

  create_table "production_categories", :force => true do |t|
    t.datetime "date_created",                                    :null => false
    t.string   "created_by",    :limit => 32,                     :null => false
    t.datetime "last_modified",                                   :null => false
    t.string   "modified_by",   :limit => 32,                     :null => false
    t.string   "name",          :limit => nil,                    :null => false
    t.boolean  "is_excluded",                  :default => false, :null => false
    t.boolean  "is_production",                :default => false, :null => false
  end

  add_index "production_categories", ["name"], :name => "production_category_name_unique", :unique => true

  create_table "rails_admin_histories", :force => true do |t|
    t.text     "message"
    t.string   "username"
    t.integer  "item"
    t.string   "table"
    t.integer  "month",      :limit => 2
    t.integer  "year",       :limit => 8
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "rails_admin_histories", ["item", "table", "month", "year"], :name => "index_rails_admin_histories"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "name"
    t.integer  "system_role_id"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

  create_table "work_chart", :force => true do |t|
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "parent_id"
    t.integer  "branch_order"
    t.string   "display_label", :limit => 100, :null => false
    t.string   "status",        :limit => 30,  :null => false
  end

  add_index "work_chart", ["parent_id"], :name => "work_chart_parent_id_display_label_unique", :unique => true
  add_index "work_chart", ["parent_id"], :name => "work_chart_parent_id_idx"

  create_table "work_chart_kind_sets", :id => false, :force => true do |t|
    t.integer "work_chart_id", :null => false
  end

  create_table "work_chart_kinds", :id => false, :force => true do |t|
    t.integer "work_chart_id",               :null => false
    t.string  "kind_code",     :limit => 30, :null => false
  end

  create_table "work_chart_kinds_defaults", :id => false, :force => true do |t|
    t.integer "work_chart_id",               :null => false
    t.string  "kind_code",     :limit => 30, :null => false
  end

  create_table "work_chart_statuses", :id => false, :force => true do |t|
    t.string   "status",        :limit => 30,                 :null => false
    t.text     "description",                 :default => "", :null => false
    t.datetime "date_created",                                :null => false
    t.string   "created_by",    :limit => 32,                 :null => false
    t.datetime "last_modified",                               :null => false
    t.string   "modified_by",   :limit => 32,                 :null => false
  end

  create_table "work_entries", :force => true do |t|
    t.datetime "date_created",                 :null => false
    t.string   "created_by",     :limit => 32, :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",    :limit => 32, :null => false
    t.integer  "work_chart_id",                :null => false
    t.integer  "role_id",                      :null => false
    t.string   "status_code",    :limit => 30, :null => false
    t.date     "date_performed",               :null => false
    t.text     "description",                  :null => false
    t.integer  "legacy_id"
  end

  add_index "work_entries", ["date_performed"], :name => "work_entries_date_performed_idx"
  add_index "work_entries", ["work_chart_id"], :name => "work_entries_work_chart_id_idx"

  create_table "work_entry_durations", :force => true do |t|
    t.datetime "date_created",                          :null => false
    t.string   "created_by",             :limit => 32,  :null => false
    t.datetime "last_modified",                         :null => false
    t.string   "modified_by",            :limit => 32,  :null => false
    t.integer  "work_entry_id",                         :null => false
    t.string   "kind_code",              :limit => 30,  :null => false
    t.integer  "production_category_id",                :null => false
    t.string   "duration",               :limit => nil, :null => false
    t.decimal  "rate"
  end

  add_index "work_entry_durations", ["work_entry_id", "kind_code"], :name => "work_entry_durations_work_entry_id_kind_code_unique", :unique => true

  create_table "work_entry_fees", :id => false, :force => true do |t|
    t.integer  "work_entry_id",                                             :null => false
    t.decimal  "fee",                         :precision => 9, :scale => 2
    t.string   "created_by",    :limit => 32,                               :null => false
    t.datetime "date_created",                                              :null => false
    t.string   "modified_by",   :limit => 32,                               :null => false
    t.datetime "last_modified",                                             :null => false
  end

  create_table "work_entry_statuses", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30, :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.string   "display_label", :limit => 50, :null => false
  end

  add_index "work_entry_statuses", ["display_label"], :name => "work_entry_statuses_display_label_unique", :unique => true

end
