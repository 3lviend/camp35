class WorkChartsController < ApplicationController
  respond_to :json

  def index
    respond_with( WorkChart.where(:status => "active", :parent_id => params[:parent_id]).order(:display_label))
  end
end
