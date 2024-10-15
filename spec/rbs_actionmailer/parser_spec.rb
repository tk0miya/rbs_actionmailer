# frozen_string_literal: true

require "rbs_actionmailer"
require_relative "../fixtures/user_mailer"

RSpec.describe RbsActionmailer::Parser do
  describe ".parse" do
    subject { described_class.parse(klass_name) }

    context "When non-existing klass_name given" do
      let(:klass_name) { "UnknownModule" }

      it { is_expected.to be nil }
    end

    context "When existing klass_name given" do
      context "When the klass_name is shallow" do
        let(:klass_name) { "Mod" }

        it "Returns a target module" do
          expect(subject).to be_instance_of(RBS::Inline::AST::Declarations::ModuleDecl)
          expect(subject.node.name).to eq :Mod
        end
      end

      context "When the klass_name is deep" do
        let(:klass_name) { "Mod::UserMailer" }

        it "Returns a target class" do
          expect(subject).to be_instance_of(RBS::Inline::AST::Declarations::ClassDecl)
          expect(subject.node.name).to eq :UserMailer
        end
      end
    end
  end
end
