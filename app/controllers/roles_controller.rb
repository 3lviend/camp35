class RolesController < ApplicationController
  before_filter :ensure_logged_in

  def current
    @current_role = current_user
  end

  def others
    #@others = IC::User.enabled
    #     .where("role_id <> ? AND email <> ?", current_user.system_role_id, "root@domain.com")
    @others = current_user.others_accessible + IC::User.where(role_id: current_user["system_role_id"])
    @others.sort_by! {|u| u.username }
  end

  def assume
    role_id = IC::User.where(email: params[:email]).first.role_id
    session[:assume_role_id] = role_id
    render :json => "ok".to_json
  end

end
