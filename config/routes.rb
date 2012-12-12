TimesheetApp::Application.routes.draw do
  mount RailsAdmin::Engine => '/admin', :as => 'rails_admin'
  
  root :to => "home#index" 
  #root :to => "work_days#index"
  match "/work_days/:weeks_from_now" => "work_days#index", as: :week_work_days
  match "/work_days/calendar/:year/:month" => "work_days#calendar", as: :calendar
  match "/work_day_entries/:year/:month/:day" => "work_day_entries#show", as: :show_work_day_entries
  match "/work_months/(:start)/(:end)" => "work_months#index",
        :constraints => { :start => /\d{4}-\d{2}-\d{2}/, :end => /\d{4}-\d{2}-\d{2}/ },
        :as => "work_months"
  resources :work_entries
  resources :work_entries, :path => "/work_day_entries/:year/:month/:day/work_entries"
  resources :work_chart_kinds, :path => "/work_charts/:work_chart_id/work_chart_kinds"
  resources :work_chart_duration_kinds, :path => "/work_charts/:work_chart_id/duration_kinds"
  resources :work_charts do
    collection do
      get 'frequent'
      get 'recent'
      get 'search'
      get 'search_all'
    end

    member do
      get 'duration_kinds'
    end
  end
  get "/roles/current" => "roles#current"
  get "/roles/others"  => "roles#others"
  get "/roles/reportable" => "roles#reportable"
  get "/roles/assume"  => "roles#assume"

  get "/reports/break" => "reports#break"

  devise_for :users, :controllers => {:sessions => 'sessions'}
end
