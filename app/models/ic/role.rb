class IC::Role < ActiveRecord::Base
  set_table_name :ic_roles

  has_and_belongs_to_many :roles, 
    :class_name  => "IC::Role",
    :join_table  => :ic_roles_has_roles,
    :foreign_key => :role_id,
    :association_foreign_key => :has_role_id
  has_many :rights,
    :class_name  => "IC::Right",
    :foreign_key => :role_id
end
