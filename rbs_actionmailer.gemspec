# frozen_string_literal: true

require_relative "lib/rbs_actionmailer/version"

Gem::Specification.new do |spec|
  spec.name = "rbs_actionmailer"
  spec.version = RbsActionmailer::VERSION
  spec.authors = ["Takeshi KOMIYA"]
  spec.email = ["i.tkomiya@gmail.com"]

  spec.summary = "A RBS files generator for ActionMailer"
  spec.description = "A RBS files generator for ActionMailer"
  spec.homepage = "https://github.com/tk0miya/rbs_actionmailer"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "actionmailer"
  spec.add_dependency "activesupport"
  spec.add_dependency "railties"
  spec.add_dependency "rake"
  spec.add_dependency "rbs"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
