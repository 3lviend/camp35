class WorkEntriesController < ApplicationController
  before_filter :ensure_logged_in
  
  respond_to :json
  before_filter :build_work_entry, :only => [:show, :update, :destroy]
  before_filter :check_user_allowed, :only => [:show, :update, :destroy]

  def show
    respond_with(@work_entry)
  end

  def update
    fee = params[:work_entry][:work_entry_fees_attributes]["0"]
    params[:work_entry].delete(:work_entry_fees_attributes)
    @work_entry.assign_attributes(params[:work_entry])
    @work_entry.work_entry_fees.build(:date_created => DateTime.now, 
                                      :created_by => current_user.email, 
                                      :last_modified => DateTime.now, 
                                      :modified_by => current_user.email, 
                                      :work_entry_id => @work_entry.id) unless @work_entry.work_entry_fees.count > 0
    @work_entry.work_entry_fees.first.fee = fee[:fee].to_f
    @work_entry.work_entry_durations.each do |d| 
      d.work_entry_id = @work_entry.id
      d.created_by = current_user.email unless d.created_by
      d.modified_by = current_user.email unless d.modified_by
    end
    kinds = params[:work_entry][:work_entry_durations_attributes].values.map {|d| d[:kind_code]}
    @work_entry.work_entry_durations.select {|d| not kinds.include?(d.kind_code)}.each(&:delete)
    if @work_entry.save
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_entry.errors.full_messages}.to_json
    end
  end

  def destroy
    @work_entry.destroy
    log_state @work_entry
    render :json => {:status => 'OK'}.to_json
  end

  def create
    @work_entry = WorkEntry.new params[:work_entry]
    @work_entry.created_by = @work_entry.modified_by = current_user.email
    @work_entry.role_id = current_user.system_role_id
    @work_entry.status_code = "unconfirmed"
    @work_entry.date_created = DateTime.now
    @work_entry.work_entry_fees.each do |f| 
      f.work_entry_id = @work_entry.id
      f.date_created = DateTime.now unless f.date_created
      f.created_by = current_user.email unless f.created_by
      f.modified_by = current_user.email
      f.last_modified = DateTime.now
    end
    @work_entry.work_entry_durations.each { |d| d.created_by = d.modified_by =  current_user.email }
    if @work_entry.save
      log_state @work_entry
      render :json => {:status => 'OK'}.to_json
    else
      render :json => {:status => 'ERROR', :errors => @work_entry.errors.full_messages}.to_json
    end
  end

  def previous_next
    base    = WorkEntry.find params[:id]
    date    = base.date_performed.to_s(:db)
    role_id = current_user.system_role_id
    prev_id = WorkEntry.where(:role_id => role_id)
                       .where("date_performed < DATE(?) OR (date_performed = DATE(?) AND id < ?)", 
                              date, date, base.id)
                       .select([:id, :date_performed])
                       .order("date_performed DESC")
                       .first.id rescue nil
    next_id = WorkEntry.where(:role_id => role_id)
                       .where("date_performed > DATE(?) OR (date_performed = DATE(?) AND id > ?)", 
                              date, date, base.id)
                       .select([:id, :date_performed])
                       .order("date_performed ASC")
                       .first.id rescue nil
    render :json => {:prev_id => prev_id, :next_id => next_id}.to_json
  end

  private
  def build_work_entry
    @work_entry = WorkEntry.includes(:work_entry_durations, :work_entry_fees)
                           .find params[:id]
  end

  def check_user_allowed
    return_401 unless @work_entry.role_id == current_user.system_role_id
  end
end
