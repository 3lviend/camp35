object @current_role
attributes :email
node :is_admin do
  @current_role.is_admin?
end
node :as do
 if @current_role.assumed_other?
  IC::Role.find(@current_role.assumed_role_id).display_label
 else
   nil
 end
end
