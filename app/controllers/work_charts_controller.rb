class WorkChartsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def index
    # key = "work_charts_#{params[:include_inactive]}_#{params[:parent_id]}"
    # @charts = Rails.cache.read key
    # unless @charts
      base = params[:include_inactive] ? WorkChart.where({}) : WorkChart.where(status: "active")
      @charts = base.where(parent_id: params[:parent_id]).order(:display_label)
      # Rails.cache.write key, @charts, :expires_in => 2.days
    # end
    respond_with @charts
  end

  def show
    key = "work_chart_#{params[:id]}"
    @chart = Rails.cache.read key
    unless @chart
      @chart = WorkChart.find params[:id]
      Rails.cache.write key, @chart, :expires_in => 2.days
    end
    respond_with @chart
  end

  def search
    render :json => WorkChart.search_for(params[:phrase]).to_json
  end

  def frequent
    key = "user_frequent_#{current_user.id}"
    # @frequents = Rails.cache.read key
    # unless @frequents
      @frequents = WorkChart.frequent_for(current_user, 20)
    #   Rails.cache.write key, @frequents, :expires_in => 2.days
    # end
    respond_with @frequents
  end

  def recent
    # key = "user_recent_#{current_user.id}"
    # @recents = Rails.cache.read key
    # unless @recents
      @recents = WorkChart.recent_for(current_user, 20)
    #  Rails.cache.write key, @recents, :expires_in => 2.days
    # end
    respond_with @recents
  end

  def duration_kinds
    respond_with WorkChart.find(params[:id]).duration_kinds 
  end

end
