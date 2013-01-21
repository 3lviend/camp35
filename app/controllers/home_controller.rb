class HomeController < ApplicationController
  def index
    render :file => File.join(Rails.root, 'public', 'brunch', 'public', 'index.html'), :layout => false
  end
end
