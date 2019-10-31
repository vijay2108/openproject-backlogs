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

OpenProject::Application.routes.draw do
  scope '', as: 'backlogs' do
    scope 'projects/:project_id', as: 'project' do
      resources :backlogs,         controller: :rb_master_backlogs,  only: :index
        resources :kanban_boards,     controller: :rb_kanban_boards do
            resources :tasks,            controller: :rb_tasks do
               member do
                  put :update_task
                end
              end
          end

      resources :sprints,          controller: :rb_sprints,          only: :update do
        resource :query,            controller: :rb_queries,          only: :show

        resource :taskboard,        controller: :rb_taskboards,       only: :show

        resource :wiki,             controller: :rb_wikis,            only: [:show, :edit]

        resource :kanban_boards,     controller: :rb_kanban_boards,       only: [:show, :edit]

        resource :burndown_chart,   controller: :rb_burndown_charts,  only: :show

        resources :impediments,      controller: :rb_impediments,      only: [:create, :update]

        resources :tasks,            controller: :rb_tasks,            only: [:create, :update]

        resources :export_card_configurations, controller: :rb_export_card_configurations, only: [:index, :show] do
          resources :stories,          controller: :rb_stories,          only: [:index]
        end

        resources :stories,          controller: :rb_stories,          only: [:create, :update]
      end
    end
  end
  get'rb_tasks/check_transition'=> 'rb_tasks#check_transition'
  get 'projects/:project_id/versions/:id/edit' => 'version_settings#edit'
  post 'projects/:id/project_done_statuses' => 'projects#project_done_statuses'
  post 'projects/:id/rebuild_positions' => 'projects#rebuild_positions'
end
