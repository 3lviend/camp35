class HomeController < ApplicationController
  #before_filter :ensure_logged_in

  def index
    render :file => File.join(Rails.root, 'public', 'brunch', 'TimesheetApp', 'public', 'index.html'), :layout => false
  end
end
