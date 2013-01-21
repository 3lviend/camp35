class WorkChartsController < ApplicationController
  before_filter :ensure_logged_in
  respond_to :json

  def index
    base = params[:include_inactive] ? WorkChart.where({}) : WorkChart.where(status: "active")
    base = base.where(parent_id: params[:parent_id]) if params[:parent_id]
    @charts = base.order(:display_label)
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

  def _search(config = {:include_hidden => false})
    render :json => WorkChart.search_for(params[:term], :include_hidden => config[:include_hidden])
                      .map { |c| {label: c["labels"].join(" - "), value: c["labels"].join(" - "), id: c["id"]}}
                      .to_json
  end

  def search
    _search
  end

  def search_all
    _search :include_hidden => true
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

  def kinds
    @kinds = params[:default_kinds] ? WorkChart.find(params[:id]).work_chart_kinds_defaults : WorkChart.find(params[:id]).work_chart_kinds
    respond_with @kinds
  end
  
  def assigned_work_entries_count
    render :json => {:count => WorkEntry.find_all_by_work_chart_id(params[:id]).count}.to_json
  end

  def create
    @work_chart = WorkChart.new params[:work_chart]
    @work_chart.created_by = @work_chart.modified_by = current_user.email
    @work_chart.date_created = DateTime.now
    if @work_chart.save
      log_state @work_chart
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_chart.errors.full_messages}.to_json
    end
  end
  
  def update
    @work_chart = WorkChart.find params[:id]
    @work_chart.assign_attributes(params[:work_chart]) if params[:work_chart]
    save_durations if params[:save_durations]
    if @work_chart.save
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_chart.errors.full_messages}.to_json
    end
  end

  def destroy
    @work_chart = WorkChart.find params[:id]
    @work_chart.destroy
    log_state @work_chart
    render :json => {:status => 'OK'}.to_json
  end

  private

  def save_durations
    WorkChartKindSet.find_by_work_chart_id(@work_chart.id).destroy rescue nil
    @work_chart.work_chart_kind_sets.create()
    @work_chart.work_chart_kinds.destroy rescue nil
    @work_chart.work_chart_kinds_defaults.destroy rescue nil
    if params[:work_chart_kinds].present?
      params[:work_chart_kinds].each do |kind|
        @work_chart.work_chart_kinds.create(:kind_code => kind)
      end
    end
    if params[:work_chart_kinds_defaults].present?
      @work_chart.work_chart_kinds_defaults.create(:kind_code => params[:work_chart_kinds_defaults])
    end
  end

end
