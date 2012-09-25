class WorkChartDurationKindsController < ApplicationController
  respond_to :json
  def index
    @kinds = WorkChartKind.where(work_chart_id: params[:work_chart_id]).map(&:duration_kind)
    respond_with @kinds
  end
end
