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

  def can_switch_roles
    self.ic_role.has_right_to IC::RightType::SUPERUSER ||
      self.others_accessible.count > 0
  end

  def others_accessible
    unless @others_accessible
      role = self.ic_role
      @others_accessible = if role.has_right_to IC::RightType::SUPERUSER
        IC::User
          .where("role_id <> ? AND email <> ?", self["system_role_id"], "root@domain.com")
      else
        IC::User.includes(:role).all.map(&:role).select do |r| 
          role.has_right_to(IC::RightType::SWITCH_USER, r) 
        end
      end
    end
    @others_accessible
  end

  def system_role_id
      self.assumed_role_id || self["system_role_id"]
  end

  def assumed_other?
    !self.assumed_role_id.nil? && (self.assumed_role_id != self["system_role_id"])
  end
  
end
