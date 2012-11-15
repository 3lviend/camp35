class WorkMonthsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json
  
  def index
    start = Date.strptime(params[:start], '%Y-%m-%d')
    _end  = Date.strptime(params[:end], '%Y-%m-%d')
    @months = WorkMonth.find_by_range current_user, start, _end
    respond_with @months
  end

end
