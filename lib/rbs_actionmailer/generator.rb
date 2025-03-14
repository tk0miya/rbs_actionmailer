# frozen_string_literal: true

require "rbs"
require "active_support/core_ext/module"

module RbsActionmailer
  class Generator
    attr_reader :klass #: singleton(ActionMailer::Base)
    attr_reader :klass_name #: String
    attr_reader :decl #: RBS::Inline::AST::Declarations::ClassDecl | RBS::Inline::AST::Declarations::ModuleDecl | nil

    # @rbs klass: singleton(ActionMailer::Base)
    def initialize(klass) #: void
      @klass = klass
      @klass_name = klass.name || ""
    end

    def generate #: String
      @decl = Parser.parse(klass_name)

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
        RBS::Writer.new(out:).write(parsed[1] + parsed[2])
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
      klass.action_methods.sort.map do |method_name|
        arg_types = arguments_for(method_name)
        singleton_method_types = arg_types.map { |args| "(#{args}) -> ActionMailer::MessageDelivery" }.join(" | ")
        instance_method_types = arg_types.map { |args| "(#{args}) -> Mail::Message" }.join(" | ")
        <<~RBS
          def self.#{method_name}: #{singleton_method_types}
          def #{method_name}: #{instance_method_types}
        RBS
      end.join("\n")
    end

    # @rbs method_name: String
    def arguments_for(method_name) #: Array[String]
      return ["*untyped"] unless decl

      member = decl.members.find do |m|
        case m
        when RBS::Inline::AST::Members::RubyDef
          m.node.name.to_s == method_name
        end
      end #: RBS::Inline::AST::Members::RubyDef?

      return ["*untyped"] unless member

      untyped = RBS::Types::Bases::Any.new(location: nil)
      member.method_overloads(untyped).map { |overload| overload.method_type.type.param_to_s }
    end

    def footer #: String
      "end\n" * klass.module_parents.size
    end
  end
end
