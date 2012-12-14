class ReportsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def break
    @items = Report.break(params[:start], params[:end], params[:roles])
    render :json => @items.to_json
  end
end
