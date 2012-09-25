TimesheetApp::Application.routes.draw do
  get "work_entries/edit"

  get "work_entries/update"

  get "work_entries/destroy"

  get "work_entries/new"

  get "work_day_entries/show"

  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'

  root :to => "work_days#index"
  match "/work_days/:weeks_from_now" => "work_days#index", as: :week_work_days
  match "/work_day_entries/:day/:month/:year" => "work_day_entries#show", as: :show_work_day_entries
  resources :work_entries, :path => "/work_day_entries/:day/:month/:year/work_entries"
  devise_for :users
end
