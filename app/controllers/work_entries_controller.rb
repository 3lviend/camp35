class WorkEntriesController < ApplicationController
  respond_to :json

  def show
    @work_entry = WorkEntry.includes(:work_entry_fees).find(params[:id])
    respond_with(@work_entry.to_json(:include => [:work_entry_fees, :work_entry_durations]))
  end

  def edit
    @work_entry = WorkEntry.find params[:id]
    @work_entry.work_entry_fees.build if @work_entry.work_entry_fees.count == 0
  end

  def update
    @work_entry = WorkEntry.includes(:work_entry_durations).find params[:id]
    if @work_entry.update_attributes(params[:work_entry])
      redirect_to show_work_day_entries_path(@day.year, @day.month, @day.day)
    else
      flash[:errors] = @work_entry.errors.full_messages
      render :edit
    end
  end

  def destroy
    @work_entry = WorkEntry.find params[:id]
    @work_entry.destroy
    redirect_to show_work_day_entries_path(@day.year, @day.month, @day.day)
  end

  def create
    @work_entry = WorkEntry.new params[:work_entry]
    @work_entry.created_by = @work_entry.modified_by = current_user.email
    @work_entry.role_id = current_user.system_role_id
    @work_entry.status_code = "unconfirmed"
    @work_entry.date_created = DateTime.now
    @work_entry.work_entry_durations.each { |d| d.created_by = d.modified_by =  current_user.email }
    if @work_entry.save
      redirect_to show_work_day_entries_path(params[:year], params[:month], params[:day])
    else
      flash[:errors] = @work_entry.errors.full_messages
      fetch_quicks
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
    @day = "#{params[:year]}-#{params[:month]}-#{params[:day]}".to_datetime
  end

  def fetch_quicks
    @quicks = WorkChart.frequently_used(current_user)
  end
end
