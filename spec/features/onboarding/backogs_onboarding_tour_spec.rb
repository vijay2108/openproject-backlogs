#-- copyright
# OpenProject is a project management system.
# Copyright (C) 2012-2018 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2017 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
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
# See docs/COPYRIGHT.rdoc for more details.
#++

require 'spec_helper'

describe 'backlogs onboarding tour', js: true do
  let(:user) { FactoryBot.create :admin }
  let(:project) { FactoryBot.create :project, name: 'My Project', identifier: 'project1', is_public: true, enabled_module_names: %w[work_package_tracking backlogs] }
  let(:sprint) { FactoryBot.create(:version, project: project, name: 'Sprint 1') }
  let(:status) { FactoryBot.create(:default_status) }
  let(:priority) { FactoryBot.create(:default_priority) }

  let(:impediment) do
    FactoryBot.build(:impediment, author: user,
                     fixed_version: sprint,
                     assigned_to: user,
                     project: project,
                     type: type_task,
                     status: status)
  end

  let(:story_type) { FactoryBot.create(:type_feature) }
  let(:task_type) do
    type = FactoryBot.create(:type_task)
    project.types << type

    type
  end

  let!(:existing_story) do
    FactoryBot.create(:work_package,
                      type: story_type,
                      project: project,
                      status: status,
                      priority: priority,
                      position: 1,
                      story_points: 3,
                      fixed_version: sprint )
  end

  before do
    login_as user
    allow(Setting).to receive(:plugin_openproject_backlogs).and_return('story_types' => [story_type.id.to_s],
                                                                       'task_type' => task_type.id.to_s)
  end

  context 'as a new user' do
    it 'I see a part of the onboarding tour in the backlogs section' do
      # Set the tour parameter so that we can start on the overview page
      visit project_path(project.id)
      page.execute_script("window.sessionStorage.setItem('openProject-onboardingTour', 'startOverviewTour');")

      expect(page).to have_text 'This is the project’s Overview page.'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'From the Project menu you can access all modules within a project.'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'In the Project settings you can configure your project’s modules.'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'Invite new Members to join your project.'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'Manage your work in the Backlogs view'

      find('.backlogs-menu-item').click
      expect(page).to have_current_path backlogs_project_backlogs_path(project)
      expect(page).to have_text 'Here you can create epics, user stories and bugs'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'To open your Task board, click on the Sprint drop-down...'

      find('.backlog .menu-trigger').click
      expect(page).to have_selector('.backlog .items', visible: true)
      expect(page).to have_text '... and select the Task board entry.'

      find('.backlog .show_task_board').click
      backlogs_project_sprint_path(sprint.id, project.id)
      expect(page).to have_text 'The Task board visualizes the progress for each sprint.'

      find('.enjoyhint_next_btn').click
      expect(page).to have_text 'Here is the Work package section'

      find('#main-menu-work-packages-wrapper .toggler').click
      expect(page).to have_text  "Let's have a look at all open Work packages"
    end
  end
end


