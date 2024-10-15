# frozen_string_literal: true

require "action_mailer"

module Mod
  class UserMailer < ActionMailer::Base
    def welcome
      mail to: "user@example.com", subject: "Welcome to our site!"
    end

    def greeting(user)
      mail to: user.email, subject: "Hello!"
    end

    #: (User user, age: Integer) -> Mail::Message
    #: (User user, address: String) -> Mail::Message
    def event(user, age: nil, address: nil) # rubocop:disable Lint/UnusedMethodArgument
      mail to: user.email, subject: "Hello!"
    end

    # @rbs user: User
    def goodbye(user)
      mail to: user.email, subject: "Good bye!"
    end
  end
end
