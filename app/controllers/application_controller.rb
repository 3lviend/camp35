class ApplicationController < ActionController::Base
  protect_from_forgery

  after_filter :dump_state_log

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  def ensure_logged_in
    unless current_user
       render :nothing => true, :status => 401
    end
  end

  # adds current state of given object along with info about
  # current action
  def log_state(object)
    @objects_state ||= {}
    @objects_state[object.object_id] = [] if @objects_state[object.object_id].nil?
    @objects_state[object.object_id] << ((object.respond_to? :to_custom_json) ? object.to_custom_json : object.to_json)
  end

  # dumps logged state in this request to disk
  # appending log/persistance.log
  def dump_state_log
    File.open(File.join(Rails.root, "log", "persistance.log"), "a") do |f|
      @objects_state.values.each do |state|
        entry = {:before => state.first}
        entry[:after] = state.last if state.count > 1
        entry[:action] = params[:action]
        entry[:controller] = params[:controller]
        f.puts entry.to_s
      end if @objects_state
    end
  end

end
