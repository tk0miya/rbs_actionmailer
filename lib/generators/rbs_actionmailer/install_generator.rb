# frozen_string_literal: true

module RbsActionmailer
  class Installgenerator < Rails::Generators::Base
    def create_raketask
      create_file "lib/tasks/rbs_actionmailer.rake", <<~RUBY
        # frozen_string_literal: true

        begin
          require "rbs_actionmailer/rake_task"

          RbsActionmailer::RakeTask.new
        rescue LoadError
          # failed to load rbs_actionmailer. Skip to load rbs_actionmailer tasks.
        end
      RUBY
    end
  end
end
