class WorkDayEntriesController < ApplicationController
  before_filter :ensure_logged_in

  def show
    @day = "#{params[:day]}/#{params[:month]}/#{params[:year]}".to_datetime
    @entries = WorkEntry.where({role_id: current_user.system_role_id, date_performed: @day})
  end
end
