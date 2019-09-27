class RbKanbanBoardsController < RbApplicationController
  menu_item :backlogs

  helper :taskboards

  def show
    @sprint = KanbanBoard.find params[:sprint_id]
    if @sprint.wi_id.present?
      @selectedworkflow = @sprint.wi_id
    else
      @selectedworkflow = 0
    end
    
    @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    @statuses = []
    @temparray = []
    @workflows.each do |workflow|
      if !@temparray.include?(workflow.old_status_id)
        @statuses.push(Status.find(workflow.old_status_id))
        @temparray.push(workflow.old_status_id)
      end
    end
    #@statuses     = Type.find(Task.type).statuses
     @sprint = KanbanBoard.find params[:sprint_id]

    # @story_ids    = @sprint.stories(@project).map(&:id)
    @last_updated = Task.where(kanban_board_id: @sprint.id) .order('updated_at DESC')
                        .order('updated_at DESC')
                        .first
  end

  def default_breadcrumb
    l(:label_backlogs)
  end
end
