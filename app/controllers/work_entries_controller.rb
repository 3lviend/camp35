class WorkEntriesController < ApplicationController
  before_filter :get_day

  def edit
  end

  def update
  end

  def destroy
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
    end
  end

  def new
    @work_entry = WorkEntry.new
    @work_entry.work_entry_fees.build
    @work_entry.work_entry_durations.build
    @work_entry.date_performed = @day
    @work_charts = WorkChart.all_with_labels
  end

  private
  def get_day
    @day = "#{params[:day]}/#{params[:month]}/#{params[:year]}".to_datetime
  end
end
