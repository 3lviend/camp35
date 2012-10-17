TimesheetApp::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  
  root :to => "home#index" 
  #root :to => "work_days#index"
  #match "/work_days/:weeks_from_now" => "work_days#index", as: :week_work_days
  #match "/work_day_entries/:year/:month/:day" => "work_day_entries#show", as: :show_work_day_entries
  resources :work_entries
  # resources :work_entries, :path => "/work_day_entries/:year/:month/:day/work_entries"
  # resources :work_chart_kinds, :path => "/work_charts/:work_chart_id/work_chart_kinds"
  #resources :work_chart_duration_kinds, :path => "/work_charts/:work_chart_id/duration_kinds"
  resources :work_charts do
    collection do
      get 'frequent'
      get 'recent'
    end
  end

  devise_for :users
end
