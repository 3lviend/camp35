class IC::User < ActiveRecord::Base
  set_table_name :ic_users

  def self.enabled
    IC::User.where(status_code: "enabled")
  end

  belongs_to :user_status, 
    :foreign_key => :status_code, 
    :primary_key => :code,
    :class_name  => "IC::UserStatus"
  belongs_to :role,
    :class_name  => "IC::Role",
    :foreign_key => :role_id


end
