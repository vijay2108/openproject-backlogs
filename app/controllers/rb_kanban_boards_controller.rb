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
    if Setting.use_default_brand == 1
      @workfows_status = WorkflowStatusDefault.where(wi_id: @selectedworkflow)
    else
      @workfows_status = WorkflowStatus.where(wi_id: @selectedworkflow)
    end

    if Setting.use_default_brand == 1
      @current_workflows = WorkflowDefault.where(type_id: Task.type, wi_id: @selectedworkflow)
    else
      @current_workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    end
    @current_workflows.each do |workflow|
      unless workflow.workflow_status_id == 0
        if Setting.use_default_brand == 1
          wf_status = WorkflowStatusDefault.find_by(id: workflow.workflow_status_id, wi_id: @selectedworkflow)
        else
          wf_status = WorkflowStatus.find_by(id: workflow.workflow_status_id, wi_id: @selectedworkflow)
        end
        p "++++++++++ WF STATUS ++++++++++++++++++++++++++++++"
        p wf_status
        p "++++++++++ WF STATUS ++++++++++++++++++++++++++++++"

        if wf_status.nil?

          # Delete al existing Workflows because of Wrong ID
          if Setting.use_default_brand == 1
            WorkflowDefault.where(wi_id: @selectedworkflow).delete_all
          else
            Workflow.where(wi_id: @selectedworkflow).delete_all
          end

          # Get all Workflow Status from Workflow Status Table
          if Setting.use_default_brand == 1
            wf_statuses = WorkflowStatusDefault.where(wi_id: @selectedworkflow)
          else
            wf_statuses = WorkflowStatus.where(wi_id: @selectedworkflow)
          end

          wf_statuses.each do |status|
            type_id = Type.find_by_name('Task').id
            role_id = Role.find_by_name('Member').id

            if Setting.use_default_brand == 1
              WorkflowDefault.create!(
                  type_id: type_id,
                  old_status_id: status.status_id,
                  new_status_id: status.status_id,
                  role_id: role_id,
                  wi_id: @selectedworkflow,
                  workflow_status_id: status.id
              )
            else
              Workflow.create!(
                  type_id: type_id,
                  old_status_id: status.status_id,
                  new_status_id: status.status_id,
                  role_id: role_id,
                  wi_id: @selectedworkflow,
                  workflow_status_id: status.id
              )
            end
          end

          if Setting.use_default_brand == 1
            status_ids = WorkflowStatusDefault.where(wi_id: @selectedworkflow).pluck(:status_id)
          else
            status_ids = WorkflowStatus.where(wi_id: @selectedworkflow).pluck(:status_id)
          end

          all_transitions = status_ids.permutation(2).to_a
          (status_ids.size - 1).times do
            all_transitions.pop
          end

          final_transitions = all_transitions

          ## Create Workflow Transition based on Transitions Collections
          final_transitions.each do |transition|
            roles = ["Member", "Admin", "Project admin", "Reader"]
            first_transition_id = transition[0]
            second_transition_id = transition[1]

            if Setting.use_default_brand == 1
              from_status = StatusDefault.find(first_transition_id).name
              to_status = StatusDefault.find(second_transition_id).name
              from_workflow_status_id = WorkflowStatusDefault.find_by(name: from_status, wi_id: @selectedworkflow).id
              to_workflow_status_id = WorkflowStatusDefault.find_by(name: to_status, wi_id: @selectedworkflow).id
            else
              from_status = Status.find(first_transition_id).name
              to_status = Status.find(second_transition_id).name
              from_workflow_status_id = WorkflowStatus.find_by(name: from_status, wi_id: @selectedworkflow).id
              to_workflow_status_id = WorkflowStatus.find_by(name: to_status, wi_id: @selectedworkflow).id
            end

            is_log_hours = status_ids.index(first_transition_id) < status_ids.index(second_transition_id) ? 1 : 0

            if Setting.use_default_brand == 1
              WorkflowTransitionDefault.create!(
                  from_workflow_status_id: from_workflow_status_id,
                  to_workflow_status_id: to_workflow_status_id,
                  is_log_hours: is_log_hours
              )

              workflow_transition_id = WorkflowTransitionDefault.find_by(from_workflow_status_id: from_workflow_status_id, to_workflow_status_id: to_workflow_status_id).id
            else
              WorkflowTransition.create!(
                  from_workflow_status_id: from_workflow_status_id,
                  to_workflow_status_id: to_workflow_status_id,
                  is_log_hours: is_log_hours
              )

              workflow_transition_id = WorkflowTransition.find_by(from_workflow_status_id: from_workflow_status_id, to_workflow_status_id: to_workflow_status_id).id
            end


            ## Create Transition Role for every Workflow Transition
            roles.each do |role|
              role_id = Role.find_or_create_by(name: role).id
              if Setting.use_default_brand == 1
                TransitionRoleDefault.create!(
                    role_id: role_id,
                    log_hours: 1,
                    workflow_transition_id: workflow_transition_id
                )
              else
                TransitionRole.create!(
                    role_id: role_id,
                    log_hours: 1,
                    workflow_transition_id: workflow_transition_id
                )
              end
            end
          end
          break
        end
      end
    end

    if Setting.use_default_brand == 1
      @workflows = WorkflowDefault.where(type_id: Task.type, wi_id: @selectedworkflow)
    else
      @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    end
    @statuses = []
    @last_status= []
    @temparray = []
    @workflows.each do |workflow|
      unless workflow.workflow_status_id == 0
          if Setting.use_default_brand == 1
            status = StatusDefault.find(WorkflowStatusDefault.find(workflow.workflow_status_id).status_id)
          else
            status = Status.find(WorkflowStatus.find(workflow.workflow_status_id).status_id)
          end
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
