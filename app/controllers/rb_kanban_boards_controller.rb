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
    @selected_workflow_information = WorkflowInformation.find_by(id: @selectedworkflow).name
    p "************* Setting ***************"
    p Setting.find_by(name: 'use_default_brand').value
    p "************* Setting ***************"
    if Setting.find_by(name: 'use_default_brand').value == 1
      p "--------Inside Default Condition === TRUE-------------"
      p base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
      p default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
      p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
      ActiveRecord::Base.establish_connection(default_brand_config)
      #ActiveRecord::Base.connect_to(:staging_243593_sancho_project) do
        p "++++++++++ Connection Successfull with Default DB +++++++++++++"
        p wi = WorkflowInformation.first
        p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
        p @workfows_status = WorkflowStatus.where(wi_id: @wi_id)
      #end
    else
      p "--------Inside Else Condition---------"
      @workfows_status = WorkflowStatus.where(wi_id: @selectedworkflow)
    end
    ActiveRecord::Base.establish_connection(base_url)
    p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    p WorkflowInformation.first
    p "$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
    p "************** WORKFLOW STATUS **************************"
    p @workfows_status
    p "************** WORKFLOW STATUS **************************"

    if Setting.find_by(name: 'use_default_brand').value == 1
      p "Inside Workflow Condition"
      p base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
      p default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
      p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
      ActiveRecord::Base.establish_connection(default_brand_config)
      #ActiveRecord::Base.connect_to(default_brand_db) do
        p "Workflows from Default DB Successfull"
        p wi = WorkflowInformation.last
        p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
        @current_workflows = Workflow.where(type_id: Task.type, wi_id: @wi_id)
      #end
    else
      @current_workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    end
    ActiveRecord::Base.establish_connection(base_url)
    p "Workflowssssssssssssssssssssss"
    p @current_workflows
    p "Workflowssssssssssssssssssssss"
    @current_workflows.each do |workflow|
      unless workflow.workflow_status_id == 0
        if Setting.find_by(name: 'use_default_brand').value == 1
          p "Inside Status"
          p base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
          p default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
          p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
          ActiveRecord::Base.establish_connection(default_brand_config)
          #ActiveRecord::Base.connect_to(default_brand_db) do
            p "Status Data from Default DB"
            p @selectedworkflow
            p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
            p wf_status = WorkflowStatus.find_by(id: workflow.workflow_status_id, wi_id: @wi_id)
          #end
        else
          wf_status = WorkflowStatus.find_by(id: workflow.workflow_status_id, wi_id: @selectedworkflow)
        end
        ActiveRecord::Base.establish_connection(base_url)
        p "++++++++++ WF STATUS ++++++++++++++++++++++++++++++"
        p wf_status
        p "++++++++++ WF STATUS ++++++++++++++++++++++++++++++"

        if wf_status.nil?

          # Delete al existing Workflows because of Wrong ID
          if Setting.find_by(name: 'use_default_brand').value == 1
            base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
            default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
            p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
            ActiveRecord::Base.establish_connection(default_brand_config)
            #ActiveRecord::Base.connect_to(default_brand_db) do
              p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
              Workflow.where(wi_id: @wi_id).delete_all
            #end
          else
            Workflow.where(wi_id: @selectedworkflow).delete_all
          end
          ActiveRecord::Base.establish_connection(base_url)

          # Get all Workflow Status from Workflow Status Table
          if Setting.find_by(name: 'use_default_brand').value == 1
            base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
            default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
            p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
            ActiveRecord::Base.establish_connection(default_brand_config)
            #ActiveRecord::Base.connect_to(default_brand_db) do
              p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
              wf_statuses = WorkflowStatus.where(wi_id: @wi_id)
            #end
          else
            wf_statuses = WorkflowStatus.where(wi_id: @selectedworkflow)
          end
          ActiveRecord::Base.establish_connection(base_url)

          wf_statuses.each do |status|
            type_id = Type.find_by_name('Task').id
            role_id = Role.find_by_name('Member').id

            if Setting.find_by(name: 'use_default_brand').value == 1
              base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
              default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
              p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
              ActiveRecord::Base.establish_connection(default_brand_config)
              #ActiveRecord::Base.connect_to(default_brand_db) do
                p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
                Workflow.create!(
                    type_id: type_id,
                    old_status_id: status.status_id,
                    new_status_id: status.status_id,
                    role_id: role_id,
                    wi_id: @wi_id,
                    workflow_status_id: status.id
                )
              #end
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
          ActiveRecord::Base.establish_connection(base_url)

          if Setting.find_by(name: 'use_default_brand').value == 1
            base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
            default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
            p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
            ActiveRecord::Base.establish_connection(default_brand_config)
            #ActiveRecord::Base.connect_to(default_brand_db) do
              p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
              status_ids = WorkflowStatus.where(wi_id: @wi_id).pluck(:status_id)
            #end
          else
            status_ids = WorkflowStatus.where(wi_id: @selectedworkflow).pluck(:status_id)
          end
          ActiveRecord::Base.establish_connection(base_url)

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

            if Setting.find_by(name: 'use_default_brand').value == 1
              base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
              default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
              p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
              ActiveRecord::Base.establish_connection(default_brand_config)
              #ActiveRecord::Base.connect_to(default_brand_db) do
                p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
                from_status = Status.find(first_transition_id).name
                to_status = Status.find(second_transition_id).name
                from_workflow_status_id = WorkflowStatus.find_by(name: from_status, wi_id: @wi_id).id
                to_workflow_status_id = WorkflowStatus.find_by(name: to_status, wi_id: @wi_id).id
              #end
            else
              from_status = Status.find(first_transition_id).name
              to_status = Status.find(second_transition_id).name
              from_workflow_status_id = WorkflowStatus.find_by(name: from_status, wi_id: @selectedworkflow).id
              to_workflow_status_id = WorkflowStatus.find_by(name: to_status, wi_id: @selectedworkflow).id
            end
            ActiveRecord::Base.establish_connection(base_url)

            is_log_hours = status_ids.index(first_transition_id) < status_ids.index(second_transition_id) ? 1 : 0

            if Setting.find_by(name: 'use_default_brand').value == 1
              base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
              default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
              p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
              ActiveRecord::Base.establish_connection(default_brand_config)
              #ActiveRecord::Base.connect_to(default_brand_db) do
                WorkflowTransition.create!(
                    from_workflow_status_id: from_workflow_status_id,
                    to_workflow_status_id: to_workflow_status_id,
                    is_log_hours: is_log_hours
                )
              #end

              workflow_transition_id = WorkflowTransitionDefault.find_by(from_workflow_status_id: from_workflow_status_id, to_workflow_status_id: to_workflow_status_id).id
            else
              WorkflowTransition.create!(
                  from_workflow_status_id: from_workflow_status_id,
                  to_workflow_status_id: to_workflow_status_id,
                  is_log_hours: is_log_hours
              )

              workflow_transition_id = WorkflowTransition.find_by(from_workflow_status_id: from_workflow_status_id, to_workflow_status_id: to_workflow_status_id).id
            end
            ActiveRecord::Base.establish_connection(base_url)


            ## Create Transition Role for every Workflow Transition
            roles.each do |role|
              role_id = Role.find_or_create_by(name: role).id
              if Setting.find_by(name: 'use_default_brand').value == 1
                base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
                default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
                p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
                ActiveRecord::Base.establish_connection(default_brand_config)
                #ActiveRecord::Base.connect_to(default_brand_db) do
                  TransitionRole.create!(
                      role_id: role_id,
                      log_hours: 1,
                      workflow_transition_id: workflow_transition_id
                  )
                #end
              else
                TransitionRole.create!(
                    role_id: role_id,
                    log_hours: 1,
                    workflow_transition_id: workflow_transition_id
                )
              end
              ActiveRecord::Base.establish_connection(base_url)
            end
          end
          break
        end
      end
    end

    if Setting.find_by(name: 'use_default_brand').value == 1
      base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
      default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
      p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
      ActiveRecord::Base.establish_connection(default_brand_config)
      #ActiveRecord::Base.connect_to(default_brand_db) do
        p @wi_id = WorkflowInformation.find_by(name: @selected_workflow_information).id
        @workflows = Workflow.where(type_id: Task.type, wi_id: @wi_id)
      #end
    else
      @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    end
    ActiveRecord::Base.establish_connection(base_url)
    @statuses = []
    @last_status= []
    @temparray = []
    @workflows.each do |workflow|
      unless workflow.workflow_status_id == 0
          if Setting.find_by(name: 'use_default_brand').value == 1
            base_url = OpenProject::Configuration.project_base_url.gsub(/https:\/\/|http:\/\//, "")
            default_brand_db = ActiveRecord::Base.configurations[base_url]["default_db"]
            p default_brand_config = ActiveRecord::Base.configurations[default_brand_db]
            ActiveRecord::Base.establish_connection(default_brand_config)
            #ActiveRecord::Base.connect_to(default_brand_db) do
              status = Status.find(WorkflowStatus.find(workflow.workflow_status_id).status_id)
            #end
          else
            status = Status.find(WorkflowStatus.find(workflow.workflow_status_id).status_id)
          end
          ActiveRecord::Base.establish_connection(base_url)
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
