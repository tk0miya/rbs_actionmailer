# frozen_string_literal: true

require "prism"
require "rbs/inline"

module RbsActionmailer
  class Parser
    # @rbs! type t = RBS::Inline::AST::Declarations::ClassDecl | RBS::Inline::AST::Declarations::ModuleDecl

    # @rbs klass_name: String
    def self.parse(klass_name) #: t?
      parser = new
      parser.parse(klass_name)
    end

    # @rbs klass_name: String
    def parse(klass_name) #: t?
      decls = load(klass_name)
      return unless decls

      names = klass_name.split("::").map(&:to_sym)
      dig(decls, *names)
    end

    private

    # @rbs klass_name: String
    def load(klass_name) #: Array[RBS::Inline::AST::Declarations::t]?
      filename, = Object.const_source_location(klass_name) #: String?
      return unless filename && File.exist?(filename)

      parse_result = Prism.parse(File.read(filename))
      _, decls, = RBS::Inline::Parser.parse(parse_result, opt_in: false)
      decls
    end

    # @rbs decls: Array[RBS::Inline::AST::Declarations::t | RBS::Inline::AST::Members::t]
    # @rbs name: Symbol
    # @rbs *remains: Symbol
    def dig(decls, name, *remains) #: t?
      decls.each do |decl|
        case decl
        when RBS::Inline::AST::Declarations::ClassDecl, RBS::Inline::AST::Declarations::ModuleDecl
          if decl.node.name == name
            return decl if remains.empty?

            return dig(decl.members, *remains)
          end
        end
      end

      nil
    end
  end
end
