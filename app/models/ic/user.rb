class IC::User < ActiveRecord::Base
  set_table_name :ic_users

  belongs_to :user_status, 
    :foreign_key => :status_code, 
    :primary_key => :code,
    :class_name  => "IC::UserStatus"
  belongs_to :role,
    :class_name  => "IC::Role",
    :foreign_key => :role_id
end
