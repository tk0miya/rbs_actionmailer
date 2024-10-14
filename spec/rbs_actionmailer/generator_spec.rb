# frozen_string_literal: true

require "rbs_actionmailer"
require "action_mailer"

RSpec.describe RbsActionmailer::Generator do
  describe "#generate" do
    subject { described_class.new(klass).generate }

    before do
      stub_const("UserMailer", klass)
    end

    let(:klass) do
      Class.new(ActionMailer::Base) do
        def welcome; end
      end
    end
    let(:expected) do
      <<~RBS
        class UserMailer < ::ActionMailer::Base
          def self.welcome: (*untyped) -> ActionMailer::MessageDelivery
          def welcome: (*untyped) -> Mail::Message
        end
      RBS
    end

    it { is_expected.to eq expected }
  end
end
