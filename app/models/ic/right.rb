class IC::Right < ActiveRecord::Base
  set_table_name :ic_rights

  attr_accessible :date_created, :created_by, :last_modified, 
                  :modified_by, :role_id, :right_type_id, :is_granted

  belongs_to :right_type,
    :class_name  => "IC::RightType",
    :foreign_key => :right_type_id

  has_many :targets,
    :class_name  => "IC::RightTarget",
    :foreign_key => :right_id

  belongs_to :role,
    :class_name  => "IC::Role",
    :foreign_key => :role_id
end
