# frozen_string_literal: true

require "pathname"
require "rake/task"

module RbsActionmailer
  class RakeTask < Rake::TaskLib
    attr_accessor :name #: Symbol
    attr_accessor :signature_root_dir #: Pathname

    # @rbs name: Symbol
    # @rbs &block: ?(self) -> void
    def initialize(name = :'rbs:actionmailer', &block) #: void
      super()

      @name = name
      @signature_root_dir = Rails.root / "sig/actionmailer"

      block&.call(self)

      define_clean_task
      define_generate_task
      define_setup_task
    end

    def define_setup_task #: void
      deps = [:"#{name}:clean", :"#{name}:generate"]

      desc "Run all tasks of rbs_actionmailer"
      task("#{name}:setup" => deps)
    end

    def define_clean_task #: void
      desc "Clean up generated RBS files"
      task("#{name}:clean": :environment) do
        sh "rm", "-rf", signature_root_dir.to_s
      end
    end

    def define_generate_task #: void
      desc "Generate RBS files for ActionMailer classes"
      task("#{name}:generate": :environment) do
        require "rbs_actionmailer" # load RbsActionMailer lazily

        Rails.application.eager_load!

        ActionMailer::Base.descendants.each do |klass|
          path = signature_root_dir / "app/mailers/#{klass.name.underscore}.rbs"
          path.dirname.mkpath
          rbs = RbsActionmailer::Generator.new(klass).generate
          path.write rbs if rbs
        end
      end
    end
  end
end
