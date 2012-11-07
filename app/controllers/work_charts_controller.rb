class WorkChartsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def index
    base = params[:include_inactive] ? WorkChart.where({}) : WorkChart.where(status: "active")
    respond_with base.where(parent_id: params[:parent_id]).order(:display_label)
  end

  def show
    respond_with WorkChart.find params[:id]
  end

  def search
    respond_with WorkChart.search_for(params[:phrase])
  end

  def frequent
    respond_with WorkChart.frequent_for(current_user, 20)
  end

  def recent
    respond_with WorkChart.recent_for(current_user, 20)
  end

  def duration_kinds
    respond_with WorkChart.find(params[:id]).duration_kinds 
  end

end
