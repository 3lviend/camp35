object @current_role
attributes :email
node :is_admin do
  @current_role.is_admin?
end
node :as, :if => lambda { |u| u.assumed_other? } do
  IC::Role.find(@current_role.assumed_role_id).display_label
end
