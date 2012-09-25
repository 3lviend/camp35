class WorkChartKindsController < ApplicationController
  respond_to :json

  def index
    @kinds = WorkChartKind.where(work_chart_id: params[:work_chart_id])
    respond_with(@kinds)
  end
end
