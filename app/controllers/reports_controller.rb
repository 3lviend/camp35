class ReportsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def break
    @items = Report.break(start: params[:start], end: params[:end], roles: params[:roles], root: params[:root], option: params[:option])
    render :json => @items.to_json
  end
end
