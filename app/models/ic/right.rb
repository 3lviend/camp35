class IC::Right < ActiveRecord::Base
  set_table_name :ic_rights

  belongs_to :right_type,
    :class_name  => "IC::RightType",
    :foreign_key => :right_type_id
end
