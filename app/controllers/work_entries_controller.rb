class WorkEntriesController < ApplicationController
  respond_to :json

  def show
    @work_entry = WorkEntry.includes(:work_entry_fees).find(params[:id])
    respond_with(@work_entry)
  end

  def edit
    @work_entry = WorkEntry.find params[:id]
    @work_entry.work_entry_fees.build if @work_entry.work_entry_fees.count == 0
  end

  def update
    @work_entry = WorkEntry.includes(:work_entry_durations).find params[:id]
    @work_entry.assign_attributes(params[:work_entry])
    @work_entry.work_entry_durations.each {|d| d.work_entry_id = @work_entry.id}
    kinds = params[:work_entry][:work_entry_durations_attributes].values.map {|d| d[:kind_code]}
    @work_entry.work_entry_durations.select {|d| not kinds.include?(d.kind_code)}.each(&:delete)
    if @work_entry.save
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_entry.errors.full_messages}.to_json
    end
  end

  def destroy
    @work_entry = WorkEntry.find params[:id]
    @work_entry.destroy
    render :json => {:status => 'OK'}.to_json
  end

  def create
    @work_entry = WorkEntry.new params[:work_entry]
    @work_entry.created_by = @work_entry.modified_by = current_user.email
    @work_entry.role_id = current_user.system_role_id
    @work_entry.status_code = "unconfirmed"
    @work_entry.date_created = DateTime.now
    @work_entry.work_entry_durations.each { |d| d.created_by = d.modified_by =  current_user.email }
    if @work_entry.save
      # redirect_to show_work_day_entries_path(params[:year], params[:month], params[:day])
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_entry.errors.full_messages}.to_json
    end
  end

  def new
    @work_entry = WorkEntry.new
    @work_entry.work_entry_fees.build
    @work_entry.work_entry_durations.build
    @work_entry.date_performed = @day
  end

  private
  def get_day
    @day = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_datetime
  end

  def fetch_quicks
    @quicks = WorkChart.frequently_used(current_user)
  end
end
