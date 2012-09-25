class WorkDaysController < ApplicationController
  before_filter :ensure_logged_in

  def index
    @days = WorkDay.by_user_and_weeks_ago(current_user, params[:weeks_from_now])
  end

end
