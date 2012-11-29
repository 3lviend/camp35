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
 
  # Equivalent of IC::M::Role.check_right Perl method
  # from old version of system
  def has_right_to(right_type_code, target)
    roles = [self]
    while roles.count > 0
      
      return true if roles.any? do |role|
        right = role.rights.select { |r| r.right_type.code == right_type_code }.first
        unless right
          false
        else
          targets = right.targets
          targets.any? do |t| 
            t.referenced.class.to_s == target.class.to_s && t.referenced.id == target.id rescue false
          end
        end
      end 

      # no luck yet - lets go deeper
      roles = roles.map(&:roles).flatten
    end
    false
  end

end
