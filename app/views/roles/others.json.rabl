collection @others
attributes :email
node :display_label do |user|
  user.role.display_label
end
