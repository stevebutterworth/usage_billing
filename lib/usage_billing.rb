# frozen_string_literal: true

require "usage_billing/usage_log"
require "usage_billing/session"
require "usage_billing/user_bill"

module UsageBilling

  class Application

    USAGE_ERROR_MSG = "Usage: bin/usage_billing LOGFILE"

    def self.run(args, output: $stdout, error: $stderr)
      new(args, output:, error:).run
    end

    def initialize(args, output:, error:)
      @args = args
      @output = output
      @error = error
      @usage_log_file = args.first
    end

    def run
      return exit_with_error(USAGE_ERROR_MSG) unless @args.length == 1
      begin
        log_text = File.read(@usage_log_file)
      rescue SystemCallError => e
        return exit_with_error(e.message)
      end
      process_log(log_text)
      0
    end

    private

    def process_log(log_text)
      usage_log = UsageLog.parse(log_text)
      usage_log.entries_by_user.each do |user, user_entries|
        sessions = Session.build_all(entries: user_entries, log_window: usage_log.log_window)
        @output.puts UserBill.new(user: user, sessions: sessions)
      end
    end

    def exit_with_error(text, code = 1)
      @error.puts text
      code
    end

  end
end
