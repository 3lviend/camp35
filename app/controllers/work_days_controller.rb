class WorkDaysController < ApplicationController
  before_filter :ensure_logged_in
  
  respond_to :json

  def index
    @days = WorkDay.by_user_and_weeks_ago(current_user, params[:weeks_from_now])
    respond_with @days
  end

  def calendar
    @days = WorkDay.by_year_and_month(current_user, params[:year], params[:month])
    respond_with @days
  end

end
