class WorkChartDurationKindsController < ApplicationController
  respond_to :json
  # caches_page :index
  def index
    @kinds = WorkChart.find(params[:work_chart_id]).duration_kinds # WorkChartKind.where(work_chart_id: params[:work_chart_id]).map(&:duration_kind)
    respond_with @kinds
  end
end
