object @current_role
attributes :email
node :can_switch_roles do
 @current_role.others_accessible.count > 0
end
node :is_admin do
 @current_role.roles.any? { |r| r.name == "admin" }
end
node :as do
 if @current_role.assumed_other?
  IC::Role.find(@current_role.assumed_role_id).display_label
 else
   nil
 end
end
