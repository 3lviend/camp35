TimesheetApp::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root :to => "work_days#index"
  match "/work_days/:weeks_from_now" => "work_days#index"
  devise_for :users
end
