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
      started_sessions = []
      completed_sessions = []
      entries.each do |entry|
        case entry.boundary_marker
        when :start
          started_sessions.push(entry.time_of_day_seconds)
        when :end
          start = started_sessions.shift || log_window.begin
          completed_sessions << new(start_at: start, end_at: entry.time_of_day_seconds)
        end
      end
      started_sessions.each do |start_time|
        completed_sessions << new(start_at: start_time, end_at: log_window.end)
      end
      completed_sessions.filter(&:valid?)
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
