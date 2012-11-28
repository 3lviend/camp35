class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :system_role_id, :role_ids

  attr_accessor :assumed_role_id

  belongs_to :ic_role,
    :class_name  => "IC::Role",
    :foreign_key => :system_role_id

  def name
    self.email
  end

  def is_admin?
    self.roles.map(&:name).include? "admin"
  end

  def others_accessible
    role = self.ic_role
    if role.rights.map(&:right_type).uniq.map(&:code).include? "superuser"
      IC::User.enabled
        .where("role_id <> ? AND email <> ?", self["system_role_id"], "root@domain.com")
    else
      rights = (role.rights + role.roles.map(&:rights)).flatten.uniq
              .select { |r| r.right_type.target_kind_code == "role" }
      accessible_group_ids = rights.map(&:targets).flatten.uniq.map(&:ref_obj_pk).uniq.map(&:to_i)
      role_ids = IC::RoleHasRole.where(has_role_id: accessible_group_ids).uniq
      IC::User.where role_id: role_ids
    end
  end

  def system_role_id
      self.assumed_role_id || self["system_role_id"]
  end

  def assumed_other?
    !self.assumed_role_id.nil? && (self.assumed_role_id != self["system_role_id"])
  end
  
end
