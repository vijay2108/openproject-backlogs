class RbKanbanBoardsController < RbApplicationController
  menu_item :backlogs

  helper :taskboards


  def create
      @kanban_board = @project.kanban_boards.new(name: params[:kanban_board]["name"],wi_id: params[:wi_id])
    if @kanban_board.save
      flash[:notice] = l(:notice_successful_create)
       redirect_to backlogs_project_sprint_kanban_boards_path(@project.identifier,@kanban_board.id)
    else       
      render action: 'new'
    end
  end

  def show
    @sprint = KanbanBoard.find params[:sprint_id]
    if @sprint.wi_id.present?
      @selectedworkflow = @sprint.wi_id
    else
      @selectedworkflow = 0
    end
    @workfows_status = WorkflowStatus.where(wi_id: @selectedworkflow)
   @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    @statuses = []
    @last_status= []
    @temparray = []
    @workflows.each do |workflow|
      unless workflow.workflow_status_id == 0
        status = Status.find(WorkflowStatus.find(workflow.workflow_status_id).status_id)
        if status.name == "Closed"
           @last_status.push(status)
           @temparray.push(workflow.old_status_id)
        else  
          @statuses.push(status)
          @temparray.push(workflow.old_status_id)
        end              
      end
    end  
     @statuses = @statuses + @last_status
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
