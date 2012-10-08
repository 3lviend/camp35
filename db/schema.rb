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

  create_table "account_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "account_kinds", ["display_label"], :name => "account_kinds_display_label_key", :unique => true

  create_table "account_transaction_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.boolean  "is_credit",                    :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "account_transaction_kinds", ["display_label"], :name => "account_transaction_kinds_display_label_key", :unique => true

  create_table "account_transactions", :force => true do |t|
    t.datetime "date_created",                   :null => false
    t.string   "created_by",      :limit => 32,  :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",     :limit => 32,  :null => false
    t.integer  "account_id",                     :null => false
    t.string   "kind_code",       :limit => 30,  :null => false
    t.string   "value",           :limit => nil, :null => false
    t.text     "notes",                          :null => false
    t.datetime "reference_stamp",                :null => false
  end

  create_table "accounts", :force => true do |t|
    t.datetime "date_created",                                  :null => false
    t.string   "created_by",    :limit => 32,                   :null => false
    t.datetime "last_modified",                                 :null => false
    t.string   "modified_by",   :limit => 32,                   :null => false
    t.integer  "reference_id",                                  :null => false
    t.string   "kind_code",     :limit => 30,                   :null => false
    t.string   "display_label", :limit => 50,                   :null => false
    t.boolean  "is_active",                   :default => true, :null => false
  end

  add_index "accounts", ["reference_id", "kind_code"], :name => "accounts_index_1"

  create_table "actions", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  create_table "approval_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "status",                       :null => false
    t.string   "display_label", :limit => 100, :null => false
    t.string   "abbr_label",    :limit => 4,   :null => false
  end

  add_index "approval_kinds", ["abbr_label"], :name => "approval_kinds_abbr_label_unique", :unique => true
  add_index "approval_kinds", ["display_label"], :name => "approval_kinds_display_label_unique", :unique => true

  create_table "communications", :force => true do |t|
    t.datetime "date_created",                                      :null => false
    t.string   "created_by",         :limit => 32,                  :null => false
    t.datetime "last_modified",                                     :null => false
    t.string   "modified_by",        :limit => 32,                  :null => false
    t.string   "description",        :limit => 100, :default => "", :null => false
    t.integer  "work_chart_id",                                     :null => false
    t.datetime "communication_date",                                :null => false
    t.string   "medium_kind",        :limit => 10,                  :null => false
    t.text     "action_taken"
    t.text     "notes"
  end

  create_table "communications_contacts_map", :id => false, :force => true do |t|
    t.integer  "communication_id",               :null => false
    t.integer  "contact_id",                     :null => false
    t.datetime "date_created",                   :null => false
    t.string   "created_by",       :limit => 32, :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",      :limit => 32, :null => false
  end

  create_table "communications_roles_map", :id => false, :force => true do |t|
    t.integer  "communication_id",               :null => false
    t.integer  "role_id",                        :null => false
    t.datetime "date_created",                   :null => false
    t.string   "created_by",       :limit => 32, :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",      :limit => 32, :null => false
  end

  create_table "config_user_work_chart_summaries", :force => true do |t|
    t.datetime "date_created",                    :null => false
    t.string   "created_by",        :limit => 32, :null => false
    t.datetime "last_modified",                   :null => false
    t.string   "modified_by",       :limit => 32, :null => false
    t.integer  "user_id",                         :null => false
    t.integer  "work_chart_id",                   :null => false
    t.string   "watch_period_code", :limit => 30, :null => false
    t.integer  "sort_order",                      :null => false
  end

  create_table "contact_item_values", :force => true do |t|
    t.datetime "date_created",                                  :null => false
    t.string   "created_by",      :limit => 32,                 :null => false
    t.datetime "last_modified",                                 :null => false
    t.string   "modified_by",     :limit => 32,                 :null => false
    t.text     "content",                       :default => "", :null => false
    t.integer  "contact_item_id"
  end

  create_table "contact_items", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "contact_id",                  :null => false
    t.string   "kind",          :limit => 50, :null => false
    t.string   "label",         :limit => 20, :null => false
  end

  create_table "contact_own_role", :id => false, :force => true do |t|
    t.integer  "contact_id",                  :null => false
    t.integer  "role_id",                     :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
  end

  create_table "contact_roles_map", :id => false, :force => true do |t|
    t.integer  "contact_id",                                   :null => false
    t.integer  "role_id",                                      :null => false
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",    :limit => 32,                  :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",   :limit => 32,                  :null => false
    t.string   "description",   :limit => 100, :default => "", :null => false
  end

  create_table "contact_work_charts_map", :id => false, :force => true do |t|
    t.integer  "contact_id",                                   :null => false
    t.integer  "work_chart_id",                                :null => false
    t.string   "description",   :limit => 100, :default => "", :null => false
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",    :limit => 32,                  :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",   :limit => 32,                  :null => false
  end

  create_table "contacts", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "status",                      :null => false
    t.string   "label",         :limit => 40
    t.string   "first_name",    :limit => 40
    t.string   "last_name",     :limit => 40
  end

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

  create_table "ic_config", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.string   "setting_code",  :limit => 50, :null => false
    t.string   "level_code",    :limit => 30, :null => false
    t.text     "ref_obj_pk"
  end

  add_index "ic_config", ["setting_code", "level_code", "ref_obj_pk"], :name => "ic_config_setting_code_key", :unique => true

  create_table "ic_config_interface_input_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "ic_config_interface_input_kinds", ["display_label"], :name => "ic_config_interface_input_kinds_display_label_key", :unique => true

  create_table "ic_config_interface_structure", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "parent_id"
    t.integer  "branch_order"
    t.string   "lookup_value",  :limit => 70, :null => false
  end

  add_index "ic_config_interface_structure", ["parent_id"], :name => "ic_config_interface_structure_parent_id_lookup_value_unique", :unique => true

  create_table "ic_config_levels", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
    t.integer  "priority",                     :null => false
  end

  add_index "ic_config_levels", ["display_label"], :name => "ic_config_levels_display_label_key", :unique => true

  create_table "ic_config_setting_level_map", :id => false, :force => true do |t|
    t.string   "setting_code",  :limit => 50, :null => false
    t.string   "level_code",    :limit => 30, :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
  end

  create_table "ic_config_setting_options", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.string   "setting_code",                :null => false
    t.string   "level_code",    :limit => 30
    t.string   "code",                        :null => false
    t.string   "display_label",               :null => false
    t.boolean  "is_default",                  :null => false
    t.integer  "sort_order"
  end

  add_index "ic_config_setting_options", ["display_label"], :name => "ic_config_setting_options_display_label_key", :unique => true
  add_index "ic_config_setting_options", ["setting_code", "level_code", "code"], :name => "ic_config_setting_options_setting_code_key", :unique => true

  create_table "ic_config_settings", :id => false, :force => true do |t|
    t.string   "code",                                    :null => false
    t.datetime "date_created",                            :null => false
    t.string   "created_by",                :limit => 32, :null => false
    t.datetime "last_modified",                           :null => false
    t.string   "modified_by",               :limit => 32, :null => false
    t.string   "display_label",                           :null => false
    t.boolean  "should_cascade",                          :null => false
    t.boolean  "should_combine",                          :null => false
    t.boolean  "is_web_editable",                         :null => false
    t.string   "interface_input_kind_code", :limit => 30, :null => false
    t.integer  "interface_node_id"
  end

  add_index "ic_config_settings", ["display_label"], :name => "ic_config_settings_display_label_key", :unique => true

  create_table "ic_config_values", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "config_id",                   :null => false
    t.integer  "option_id",                   :null => false
  end

  create_table "ic_file_properties", :force => true do |t|
    t.datetime "date_created",                        :null => false
    t.string   "created_by",            :limit => 32, :null => false
    t.datetime "last_modified",                       :null => false
    t.string   "modified_by",           :limit => 32, :null => false
    t.integer  "file_id"
    t.integer  "file_resource_attr_id"
    t.text     "value",                               :null => false
  end

  create_table "ic_file_resource_attr_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
    t.text     "description",                  :null => false
  end

  create_table "ic_file_resource_attrs", :force => true do |t|
    t.datetime "date_created",                    :null => false
    t.string   "created_by",       :limit => 32,  :null => false
    t.datetime "last_modified",                   :null => false
    t.string   "modified_by",      :limit => 32,  :null => false
    t.integer  "file_resource_id",                :null => false
    t.string   "code",             :limit => 100, :null => false
    t.string   "kind_code",        :limit => 30,  :null => false
    t.string   "display_label",    :limit => 100, :null => false
    t.text     "description",                     :null => false
  end

  add_index "ic_file_resource_attrs", ["file_resource_id", "code"], :name => "ic_file_resource_attrs_file_resource_id_key", :unique => true

  create_table "ic_file_resources", :force => true do |t|
    t.datetime "date_created",                       :null => false
    t.string   "created_by",           :limit => 32, :null => false
    t.datetime "last_modified",                      :null => false
    t.string   "modified_by",          :limit => 32, :null => false
    t.integer  "parent_id"
    t.integer  "branch_order"
    t.string   "lookup_value",         :limit => 70, :null => false
    t.boolean  "generate_from_parent",               :null => false
  end

  add_index "ic_file_resources", ["parent_id"], :name => "ic_file_resources_parent_id_lookup_value_unique", :unique => true

  create_table "ic_files", :force => true do |t|
    t.datetime "date_created",                   :null => false
    t.string   "created_by",       :limit => 32, :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",      :limit => 32, :null => false
    t.integer  "file_resource_id"
    t.text     "object_pk",                      :null => false
  end

  add_index "ic_files", ["file_resource_id", "object_pk"], :name => "ic_files_file_resource_id_key", :unique => true

  create_table "ic_hash_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "ic_hash_kinds", ["display_label"], :name => "ic_hash_kinds_display_label_key", :unique => true

  create_table "ic_manage_class_actions", :force => true do |t|
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "class_code",    :limit => 100, :null => false
    t.string   "code",          :limit => 100, :null => false
    t.string   "display_label",                :null => false
    t.boolean  "is_primary",                   :null => false
  end

  add_index "ic_manage_class_actions", ["class_code", "code"], :name => "ic_manage_class_actions_class_code_key", :unique => true
  add_index "ic_manage_class_actions", ["class_code", "display_label"], :name => "ic_manage_class_actions_display_label_key", :unique => true

  create_table "ic_manage_classes", :id => false, :force => true do |t|
    t.string   "code",          :limit => 100, :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
  end

  create_table "ic_manage_menu_items", :force => true do |t|
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",                     :limit => 32, :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",                    :limit => 32, :null => false
    t.integer  "parent_id"
    t.integer  "branch_order"
    t.string   "lookup_value",                   :limit => 70, :null => false
    t.integer  "manage_class_action_id"
    t.string   "manage_class_action_addtl_args"
  end

  add_index "ic_manage_menu_items", ["parent_id"], :name => "ic_manage_menu_items_parent_id_lookup_value_unique", :unique => true

  create_table "ic_periods", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "ic_periods", ["display_label"], :name => "ic_periods_display_label_key", :unique => true

  create_table "ic_right_targets", :id => false, :force => true do |t|
    t.integer  "id",                          :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "right_id",                    :null => false
    t.text     "ref_obj_pk",                  :null => false
  end

  create_table "ic_right_type_target_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.string   "display_label", :limit => 100, :null => false
    t.string   "model_class",   :limit => 100, :null => false
    t.string   "relation_name", :limit => 100, :null => false
  end

  add_index "ic_right_type_target_kinds", ["display_label"], :name => "ic_right_type_target_kinds_display_label_key", :unique => true
  add_index "ic_right_type_target_kinds", ["model_class"], :name => "ic_right_type_target_kinds_model_class_key", :unique => true
  add_index "ic_right_type_target_kinds", ["relation_name"], :name => "ic_right_type_target_kinds_relation_name_key", :unique => true

  create_table "ic_right_types", :force => true do |t|
    t.datetime "date_created",                                    :null => false
    t.string   "created_by",       :limit => 32,                  :null => false
    t.datetime "last_modified",                                   :null => false
    t.string   "modified_by",      :limit => 32,                  :null => false
    t.string   "code",             :limit => 50,                  :null => false
    t.string   "display_label",    :limit => 100,                 :null => false
    t.text     "description",                     :default => "", :null => false
    t.string   "target_kind_code", :limit => 30
  end

  add_index "ic_right_types", ["code", "target_kind_code"], :name => "ic_right_types_code_key", :unique => true

  create_table "ic_rights", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "role_id",                     :null => false
    t.integer  "right_type_id",               :null => false
    t.boolean  "is_granted",                  :null => false
  end

  add_index "ic_rights", ["role_id", "right_type_id", "is_granted"], :name => "ic_rights_role_id_key", :unique => true

  create_table "ic_roles", :force => true do |t|
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",    :limit => 32,                  :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",   :limit => 32,                  :null => false
    t.string   "code",          :limit => 50,                  :null => false
    t.string   "display_label", :limit => 100,                 :null => false
    t.text     "description",                  :default => "", :null => false
  end

  add_index "ic_roles", ["code"], :name => "ic_roles_code_key", :unique => true

  create_table "ic_roles_has_roles", :id => false, :force => true do |t|
    t.integer  "role_id",                     :null => false
    t.integer  "has_role_id",                 :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
  end

  create_table "ic_time_zones", :id => false, :force => true do |t|
    t.string   "code",          :limit => 50, :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.decimal  "utc_offset"
    t.boolean  "is_visible",                  :null => false
  end

  create_table "ic_user_statuses", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30, :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.string   "display_label", :limit => 50, :null => false
  end

  add_index "ic_user_statuses", ["display_label"], :name => "ic_user_statuses_display_label_key", :unique => true

  create_table "ic_user_versions", :id => false, :force => true do |t|
    t.integer  "id",                          :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.string   "display_label", :limit => 50, :null => false
  end

  add_index "ic_user_versions", ["display_label"], :name => "ic_user_versions_display_label_key", :unique => true

  create_table "ic_users", :force => true do |t|
    t.datetime "date_created",                                                :null => false
    t.string   "created_by",                :limit => 32,                     :null => false
    t.datetime "last_modified",                                               :null => false
    t.string   "modified_by",               :limit => 32,                     :null => false
    t.integer  "role_id",                                                     :null => false
    t.integer  "version_id",                                                  :null => false
    t.string   "status_code",               :limit => 30,                     :null => false
    t.string   "username",                  :limit => 30,                     :null => false
    t.string   "email",                     :limit => 100,                    :null => false
    t.string   "password",                  :limit => 40,                     :null => false
    t.string   "password_hash_kind_code",   :limit => 30,                     :null => false
    t.date     "password_expires_on"
    t.boolean  "password_force_reset",                     :default => false, :null => false
    t.integer  "password_failure_attempts", :limit => 2,   :default => 0,     :null => false
    t.string   "time_zone_code",            :limit => 50,                     :null => false
  end

  add_index "ic_users", ["username"], :name => "ic_users_username_key", :unique => true

  create_table "ic_versions", :id => false, :force => true do |t|
    t.integer  "id",                          :null => false
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
  end

  create_table "lookup_contact_item_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 50,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "status",                       :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  create_table "lookup_medium_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 10,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "status",                       :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  create_table "lookups", :force => true do |t|
    t.datetime "date_created",                   :null => false
    t.string   "created_by",      :limit => 32,  :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",     :limit => 32,  :null => false
    t.integer  "status",                         :null => false
    t.integer  "style",                          :null => false
    t.string   "model",           :limit => 200, :null => false
    t.string   "label",           :limit => 50,  :null => false
    t.string   "display_label",   :limit => 100, :null => false
    t.boolean  "is_web_editable",                :null => false
  end

  add_index "lookups", ["label"], :name => "lookups_label_unique", :unique => true

  create_table "planned_communications", :force => true do |t|
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",    :limit => 32,                  :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",   :limit => 32,                  :null => false
    t.integer  "work_chart_id",                                :null => false
    t.datetime "target_date",                                  :null => false
    t.string   "description",   :limit => 100, :default => "", :null => false
    t.string   "medium_kind",   :limit => 10,                  :null => false
  end

  create_table "planned_communications_contacts_map", :id => false, :force => true do |t|
    t.integer  "planned_communication_id",               :null => false
    t.integer  "contact_id",                             :null => false
    t.datetime "date_created",                           :null => false
    t.string   "created_by",               :limit => 32, :null => false
    t.datetime "last_modified",                          :null => false
    t.string   "modified_by",              :limit => 32, :null => false
  end

  create_table "planned_communications_roles_map", :id => false, :force => true do |t|
    t.integer  "planned_communication_id",               :null => false
    t.integer  "role_id",                                :null => false
    t.datetime "date_created",                           :null => false
    t.string   "created_by",               :limit => 32, :null => false
    t.datetime "last_modified",                          :null => false
    t.string   "modified_by",              :limit => 32, :null => false
  end

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

  create_table "tag_set_kinds", :id => false, :force => true do |t|
    t.string   "code",          :limit => 30,  :null => false
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "status",                       :null => false
    t.string   "display_label", :limit => 100, :null => false
  end

  add_index "tag_set_kinds", ["display_label"], :name => "tag_set_kinds_display_label_unique", :unique => true

  create_table "tag_set_tags", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "tag_set_id",                  :null => false
    t.string   "display_label", :limit => 30, :null => false
  end

  create_table "tag_sets", :force => true do |t|
    t.datetime "date_created",                     :null => false
    t.string   "created_by",         :limit => 32, :null => false
    t.datetime "last_modified",                    :null => false
    t.string   "modified_by",        :limit => 32, :null => false
    t.string   "kind_code",          :limit => 30, :null => false
    t.string   "display_label",      :limit => 50, :null => false
    t.boolean  "is_single_use",                    :null => false
    t.boolean  "mutually_exclusive",               :null => false
  end

  add_index "tag_sets", ["kind_code", "display_label"], :name => "tag_sets_kind_code_display_label_unique", :unique => true

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

  create_table "work_chart_notes", :force => true do |t|
    t.datetime "date_created",                                 :null => false
    t.string   "created_by",    :limit => 32,                  :null => false
    t.datetime "last_modified",                                :null => false
    t.string   "modified_by",   :limit => 32,                  :null => false
    t.integer  "work_chart_id",                                :null => false
    t.string   "subject",       :limit => 100,                 :null => false
    t.text     "content",                      :default => "", :null => false
  end

  create_table "work_chart_statuses", :id => false, :force => true do |t|
    t.string   "status",        :limit => 30,                 :null => false
    t.text     "description",                 :default => "", :null => false
    t.datetime "date_created",                                :null => false
    t.string   "created_by",    :limit => 32,                 :null => false
    t.datetime "last_modified",                               :null => false
    t.string   "modified_by",   :limit => 32,                 :null => false
  end

  create_table "work_chart_tag_set_map", :id => false, :force => true do |t|
    t.integer  "work_chart_id",                  :null => false
    t.integer  "tag_set_id",                     :null => false
    t.datetime "date_created",                   :null => false
    t.string   "created_by",       :limit => 32, :null => false
    t.datetime "last_modified",                  :null => false
    t.string   "modified_by",      :limit => 32, :null => false
    t.boolean  "children_inherit",               :null => false
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

  create_table "work_entry_approvals", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "work_entry_id",               :null => false
    t.string   "kind_code",     :limit => 30, :null => false
    t.integer  "role_id"
    t.boolean  "is_approved",                 :null => false
    t.datetime "approved_at",                 :null => false
    t.string   "approved_by",   :limit => 32, :null => false
  end

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

  create_table "work_entry_logs", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "work_entry_id",               :null => false
    t.string   "action_code",   :limit => 30, :null => false
  end

  create_table "work_entry_notes", :force => true do |t|
    t.datetime "date_created",                 :null => false
    t.string   "created_by",    :limit => 32,  :null => false
    t.datetime "last_modified",                :null => false
    t.string   "modified_by",   :limit => 32,  :null => false
    t.integer  "work_entry_id",                :null => false
    t.string   "subject",       :limit => 100, :null => false
    t.text     "content",                      :null => false
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

  create_table "work_entry_tags", :force => true do |t|
    t.datetime "date_created",                :null => false
    t.string   "created_by",    :limit => 32, :null => false
    t.datetime "last_modified",               :null => false
    t.string   "modified_by",   :limit => 32, :null => false
    t.integer  "work_entry_id",               :null => false
    t.integer  "tag_id",                      :null => false
  end

end
