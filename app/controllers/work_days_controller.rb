class WorkDaysController < ApplicationController

  def index
    @days = WorkDay.by_user_and_weeks_ago(params[:weeks_from_now])
  end

end
