# frozen_string_literal: true

require "rbs_actionmailer"
require "action_mailer"
require_relative "../fixtures/user_mailer"

RSpec.describe RbsActionmailer::Generator do
  describe "#generate" do
    subject { described_class.new(klass).generate }

    before do
      stub_const("UserMailer", klass)
    end

    let(:klass) { Mod::UserMailer }
    let(:expected) do
      <<~RBS
        module Mod
          class UserMailer < ::ActionMailer::Base
            def self.event: (User user, age: Integer) -> ActionMailer::MessageDelivery
                          | (User user, address: String) -> ActionMailer::MessageDelivery

            def self.goodbye: (User user) -> ActionMailer::MessageDelivery

            def self.greeting: (untyped user) -> ActionMailer::MessageDelivery

            def self.welcome: () -> ActionMailer::MessageDelivery
          end
        end
      RBS
    end

    it { is_expected.to eq expected }
  end
end
