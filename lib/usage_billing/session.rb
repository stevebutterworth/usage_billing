# frozen_string_literal: true

# Creates sessions from log entries
# Assumptions
#  * FIFO for overlapping sessions
#  * Use logs window bounds for orphaned start and end entries
#
module UsageBilling

  Session = Data.define(:start_at, :end_at) do

    def self.build_all(entries:, log_window:)
      return [] if entries.nil? || entries.empty?
      return [] if log_window.nil? || log_window.begin.nil? || log_window.end.nil?
      live_session_starts = []
      complete_sessions = []
      entries.each do |entry|
        case entry.boundary_marker
        when :start
          live_session_starts.push(entry.time_of_day_seconds)
        when :end
          start = live_session_starts.shift() || log_window.begin
          session = UsageBilling::Session.new(start_at: start, end_at: entry.time_of_day_seconds)
          complete_sessions << session if session.valid?
        end
      end
      live_session_starts.each do |start_time|
        session = UsageBilling::Session.new(start_at: start_time, end_at: log_window.end)
        complete_sessions << session if session.valid?
      end
      complete_sessions
    end

    def valid?
      !(start_at.nil? || end_at.nil? || end_at < start_at)
    end

    def duration
      return nil unless valid?
      end_at - start_at
    end

  end

end