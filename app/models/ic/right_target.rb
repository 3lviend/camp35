class IC::RightTarget < ActiveRecord::Base
  set_table_name :ic_right_targets

  belongs_to :right,
    :class_name  => "IC::Right",
    :foreign_key => :right_id

  def referenced
    unless @referenced
      case self.right.right_type.target_kind_code
      when "role"
        IC::Role.find self.ref_obj_pk.to_i
      else
        throw "Unimplemented right target referencing for code #{self.right.right_type.target_kind_code}"
      end
    end
    @referenced
  end

end
