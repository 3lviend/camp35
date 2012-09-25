class WorkEntriesController < ApplicationController
  before_filter :get_day
  before_filter :fetch_work_charts, :only => [:new, :edit]

  def edit
    @work_entry = WorkEntry.find params[:id]
  end

  def update
    @work_entry = WorkEntry.find params[:id]
    if @work_entry.update_attributes(params[:work_entry])
      redirect_to show_work_day_entries_path(@day.day, @day.month, @day.year)
    else
      flash[:errors] = @work_entry.errors.full_messages
      render :edit
    end
  end

  def destroy
    @work_entry = WorkEntry.find params[:id]
    @work_entry.destroy
    redirect_to show_work_day_entries_path(@day.day, @day.month, @day.year)
  end

  def create
    @work_entry = WorkEntry.new params[:work_entry]
    @work_entry.created_by = @work_entry.modified_by = current_user.email
    @work_entry.role_id = current_user.system_role_id
    @work_entry.status_code = "unconfirmed"
    @work_entry.date_created = DateTime.now
    @work_entry.work_entry_durations.last.created_by = @work_entry.work_entry_durations.last.modified_by = current_user.email
    @work_entry.work_entry_durations.last.kind_code = "billable_standard"
    if @work_entry.save
      redirect_to show_work_day_entries_path(@day.day, @day.month, @day.year)
    else
      flash[:errors] = @work_entry.errors.full_messages
      fetch_work_charts
      render :new
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
    @day = "#{params[:day]}/#{params[:month]}/#{params[:year]}".to_datetime
  end

  def fetch_work_charts
    @work_charts = WorkChart.all_with_labels
  end
end
