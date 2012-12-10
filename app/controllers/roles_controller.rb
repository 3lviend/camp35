class RolesController < ApplicationController
  before_filter :ensure_logged_in

  def current
    @current_role = current_user
  end

  def others
    @others = current_user.others_accessible + IC::User.where(role_id: current_user["system_role_id"])
    @others.sort_by! {|u| u.username }
  end

  def reportable
    @roles = current_user.reportable_users.sort_by { |u| u.username }
  end

  def assume
    role_id = IC::User.where(email: params[:email]).first.role_id
    session[:assume_role_id] = role_id
    render :json => "ok".to_json
  end

end
