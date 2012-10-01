class WorkChartsController < ApplicationController
  respond_to :json

  def index
    respond_with( WorkChart.all_with_labels)
  end
end
