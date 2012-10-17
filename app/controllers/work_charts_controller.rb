class WorkChartsController < ApplicationController
  respond_to :json

  def index
    base = params[:include_inactive] ? WorkChart.where(status: "active") : WorkChart.where({})
    respond_with base.where(parent_id: params[:parent_id]).order(:display_label)
  end

  def show
    respond_with WorkChart.find params[:id]
  end

  def frequent
    respond_with WorkChart.frequent_for(current_user, 20)
  end

  def recent
    respond_with WorkChart.recent_for(current_user, 20)
  end

end
