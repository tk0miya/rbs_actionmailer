# frozen_string_literal: true

require "action_mailer"

module Mod
  class UserMailer < ActionMailer::Base
    def welcome
      mail to: "user@example.com", subject: "Welcome to our site!"
    end

    # @rbs user: untyped
    def goodbye(user)
      mail to: user.email, subject: "Good bye!"
    end
  end
end
