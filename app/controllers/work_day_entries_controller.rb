class WorkDayEntriesController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def show
    @day = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_datetime
    @entries = WorkEntry.where({role_id: current_user.system_role_id, date_performed: @day})
  end
end
