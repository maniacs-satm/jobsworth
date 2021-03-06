require 'test_helper'

class TypeValidationTest < ActionDispatch::IntegrationTest
  context 'A logged in user with existings projects' do
    setup do
      @user = login
      @project = project_with_some_tasks(@user)
      @milestone = Milestone.make(:project => @project, :user => @user,
                                  :company => @project.company)
    end
    context "when the Type property is mandatory and task's Type is not selected" do
      setup do
        type= @user.company.properties.where('name=?', 'Type').first
        type.mandatory= true
        type.save!
      end

      context 'creating a new task' do
        setup do
          @task_count = TaskRecord.count
          visit '/'
          click_link 'Task'
        end

        should 'task should be created' do
          assert_equal @task_count+1, TaskRecord.count
          assert page.has_content? "Task was created."
        end
      end

      context 'when edit task' do
        setup do
          @task= @project.tasks.first
          visit "/tasks/#{@task.task_num.to_s}/edit"
        end

        should 'be validation message: Type is required, and task sould not be saved' do
          fill_in 'task_description', :with => 'Should not be saved descr'
          select '', :from => 'Type'
          click_button 'Save'
          @task.reload
          assert page.has_content?("Type can't be blank")
          assert_not_equal 'Should not be saved descr', @task.description
        end
      end
    end
  end
end
