# frozen_string_literal: true

require "rbs"
require "active_support/core_ext/module"

module RbsActionmailer
  class Generator
    attr_reader :klass #: singleton(ActionMailer::Base)
    attr_reader :klass_name #: String

    # @rbs klass: singleton(ActionMailer::Base)
    def initialize(klass) #: void
      @klass = klass
      @klass_name = klass.name || ""
    end

    def generate #: String
      format <<~RBS
        #{header}
        #{methods}
        #{footer}
      RBS
    end

    private

    # @rbs rbs: String
    def format(rbs) #: String
      parsed = RBS::Parser.parse_signature(rbs)
      StringIO.new.tap do |out|
        RBS::Writer.new(out: out).write(parsed[1] + parsed[2])
      end.string
    end

    def header #: String
      namespace = +""
      klass_name.split("::").map do |mod_name|
        namespace += "::#{mod_name}"
        mod_object = Object.const_get(namespace)
        case mod_object
        when Class
          # @type var superclass: Class
          superclass = _ = mod_object.superclass
          superclass_name = superclass.name || "Object"

          "class #{mod_name} < ::#{superclass_name}"
        when Module
          "module #{mod_name}"
        else
          raise "unreachable"
        end
      end.join("\n")
    end

    def methods #: String
      klass.action_methods.map do |method_name|
        <<~RBS
          def self.#{method_name}: (*untyped) -> ActionMailer::MessageDelivery
          def #{method_name}: (*untyped) -> Mail::Message
        RBS
      end.join("\n")
    end

    def footer #: String
      "end\n" * klass.module_parents.size
    end
  end
end
