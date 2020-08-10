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

class RbTaskboardsController < RbApplicationController
  menu_item :backlogs

  helper :taskboards

  def show
  	if !@project.kanban_boards.present?
 
  		    @currentworkflow = ProjectWorkflow.find_by(project_id: @project.id)
  		    if @currentworkflow
  		      @selectedworkflow = @currentworkflow.wi_id
  		    else
  		      @selectedworkflow = 3
  		    end
  		    # @kanban_board = @project.kanban_boards.new
          if Setting.use_default_brand == 1
            @workflows = WorkflowDefault.where(type_id: Task.type, wi_id: @selectedworkflow)
          else
            @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
          end
  		    @statuses = []
  		    @temparray = []
  		    @workflows.each do |workflow|
  		      if !@temparray.include?(workflow.old_status_id)
              if Setting.use_default_brand == 1
                @statuses.push(StatusDefault.find(workflow.old_status_id))
              else
                @statuses.push(Status.find(workflow.old_status_id))
              end
  		        @temparray.push(workflow.old_status_id)
  		      end
  		    end
  		    #@statuses     = Type.find(Task.type).statuses
  		    @story_ids    = @sprint.stories(@project).map(&:id)
  		    @last_updated = Task.where(parent_id: @story_ids)
  		                        .order('updated_at DESC')
  		                        .first

    else		
    @currentworkflow = ProjectWorkflow.find_by(project_id: @project.id)
    if @currentworkflow
      @selectedworkflow = @currentworkflow.wi_id
    else
      @selectedworkflow = 0
    end
    @kanban_board = @project.kanban_boards.new
    @kanban_boards = @project.kanban_boards
    if Setting.use_default_brand == 1
      @workflow_informations = WorkflowInformationDefault.where(id: @kanban_boards.collect(&:wi_id))
      @workflow_status = WorkflowStatusDefault.where( wi_id: @workflow_informations.collect(&:id))
    else
      @workflow_informations = WorkflowInformation.where(id: @kanban_boards.collect(&:wi_id))
      @workflow_status = WorkflowStatus.where( wi_id: @workflow_informations.collect(&:id))
    end
    # @statuses = Status.where(id: @workflow_status.collect(&:status_id).uniq)
    @statuses = []
    @last_status= []
    @workflow_status.each do |workflow_status|
        if Setting.use_default_brand == 1
          status = StatusDefault.find(workflow_status.status_id)
        else
          status = Status.find(workflow_status.status_id)
        end
        if status.name == "Closed"
           @last_status.push(status)
           # @temparray.push(workflow.old_status_id)
        else  
          @statuses.push(status)
          # @temparray.push(workflow.old_status_id)
        end              
    end  
    @statuses = (@statuses + @last_status).uniq

    # @workflows = Workflow.where(type_id: Task.type, wi_id: @selectedworkflow)
    @temparray = []
    # @workflow_status.each do |workflow_status|
    #     @statuses.push(Status.find(workflow_status.status_id))
    #     # @temparray.push(workflow.old_status_id)
    # end
    #@statuses     = Type.find(Task.type).statuses
    @story_ids    = Task.where(type_id: Task.type, kanban_board_id: @kanban_boards.collect(&:id).compact)
    # @last_updated = Task.where(parent_id: @story_ids)
    #                     .order('updated_at DESC')
    #                     .first
    end
  end

  def default_breadcrumb
    l(:label_backlogs)
  end
end
