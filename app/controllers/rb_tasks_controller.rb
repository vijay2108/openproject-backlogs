#-- copyright
# OpenProject Backlogs Plugin
#
# Copyright (C)2013-2014 the OpenProject Foundation (OPF)
# Copyright (C)2011 Stephan Eckardt, Tim Felgentreff, Marnen Laibow-Koser, Sandro Munda
# Copyright (C)2010-2011 friflaj
# Copyright (C)2010 Maxime Guilbot, Andrew Vit, Joakim Kolsjö, ibussieres, Daniel Passos, Jason Vasquez, jpic, Emiliano Heyns
# Copyright (C)2009-2010 Mark Maglana
# Copyright (C)2009 Joe Heck, Nate Lowrie
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License version 3.
#
# OpenProject Backlogs is a derivative work based on ChiliProject Backlogs.
# The copyright follows:
# Copyright (C) 2010-2011 - Emiliano Heyns, Mark Maglana, friflaj
# Copyright (C) 2011 - Jens Ulferts, Gregor Schmidt - Finn GmbH - Berlin, Germany
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.rdoc for more details.
#++

class RbTasksController < RbApplicationController

  # This is a constant here because we will recruit it elsewhere to whitelist
  # attributes. This is necessary for now as we still directly use `attributes=`
  # in non-controller code.
  PERMITTED_PARAMS = ["id", "type_id", "priority_id", "subject", "assigned_to_id", "remaining_hours", "parent_id",
                      "estimated_hours", "status_id", "prev", "sprint_id"]


  def create
    @task = Task.create_with_relationships(task_params, @project.id)

    status = (@task.errors.empty? ? 200 : 400)
    @include_meta = true

    respond_to do |format|
      format.html { render partial: 'task', object: @task, status: status }
    end
  end

  def update
    @task = Task.find(task_params[:id])
    task_params_new  =@task.kanban_board.present? ?  task_params.except(:sprint_id) : task_params
    result = @task.update_with_relationships(task_params_new)
    status = (result ? 200 : 400)
    @include_meta = true
    respond_to do |format|
      format.html { render partial: 'task', object: @task, status: status }
    end
  end

  def update_task
     @task = Task.find(task_params[:id])
      @task = Task.find(params[:parent_id]) if params[:parent_id].present?
       task_params_new  =@task.kanban_board.present? ?  task_params.except(:sprint_id) : task_params
       @time_entry = new_time_entry(@project,WorkPackage.find(@task.id), {hours: params[:log_hour].present? ? params[:log_hour] : 0})
       if @time_entry.save
         result = @task.update_with_relationships(task_params_new)
         status = (result ? 200 : 400) 
       else
          status = 400 
       end
    #    @time_entry = TimelogController.new.create(@project, @task, params[:log_hour].to_h)

    # TimelogController.save_time_entry_and_respond @time_entry
       @include_meta = true
       respond_to do |format|
         format.html { render partial: 'task', object: @task, status: status }
       end
  end  


  def check_transition
    @t  =Task.find params[:parent_id]
    @kanban_board =  KanbanBoard.find @t.kanban_board_id
    from = WorkflowStatus.find_by_status_id_and_wi_id(@t.status_id, @kanban_board.wi_id)
    to =  WorkflowStatus.find_by_status_id_and_wi_id(params[:status_id], @kanban_board.wi_id)
    @workflowInformation = WorkflowInformation.find @kanban_board.wi_id 
    @workfow_transition = WorkflowTransition.where(from_workflow_status_id: from.id , to_workflow_status_id: to.id)
    respond_to do |format|
      if @workfow_transition.present? 
        if @workfow_transition.last.is_log_hours==true
         format.json {render :json => {:success => true } }
        else
          format.json {render :json => {:success => false } }
        end  
      else
        format.json {render :json => {:success => false } }
      end  
    end
  end 

  
  def new_time_entry(project, work_package, attributes)
    time_entry = TimeEntry.new(project: project,
                               work_package: work_package,
                               user: User.current,
                               spent_on: User.current.today)

    time_entry.attributes = attributes

    time_entry
  end

  def save_time_entry_and_respond(time_entry)
    # call_hook(:controller_timelog_edit_before_save, params: params, time_entry: time_entry)

    # if @time_entry.save
    #   respond_to do |format|
    #     format.html do
    #       flash[:notice] = l(:notice_successful_update)
    #       redirect_back_or_default action: 'index', project_id: time_entry.project
    #     end
    #   end
    # else
    #   respond_to do |format|
    #     format.html do
    #       render action: 'edit'
    #     end
    #   end
    # end
  end
  private
  def task_params
    params.permit(PERMITTED_PARAMS)
  end
end
