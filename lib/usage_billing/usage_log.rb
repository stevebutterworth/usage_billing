# frozen_string_literal: true

# Responsible for parsing and storing usage log entries
# Expects log entries in below format
# 12:23:48 USERNAME Start
# 12:23:50 USERNAME End

module UsageBilling

  class UsageLog

    Entry = Data.define(:time_of_day_seconds, :user, :boundary_marker)

    attr_reader :entries, :log_window

    def self.parse(text)
      new(entries: parse_text(text))
    end

    def initialize(entries:)
      @entries = (entries || []).compact
      unless @entries.empty?
        @log_window = (entries.first.time_of_day_seconds..entries.last.time_of_day_seconds)
      end
    end

    def entries_by_user = @entries.group_by(&:user).sort.to_h

    class << self

      private

      def parse_text(text)
        text ||= ""
        text.each_line.filter_map { |line| parse_line(line) }
      end

      def parse_line(raw_line)
        line = raw_line.strip
        return nil if line.empty?

        fields = line.split(" ")
        return nil if fields.length < 3

        time_of_day_seconds = time_to_seconds(fields.first)
        return nil if time_of_day_seconds.nil?

        boundary_marker = parse_boundary(fields[2])
        return nil if boundary_marker.nil?

        Entry.new(time_of_day_seconds:, user: fields[1], boundary_marker:)
      end

      # Don't trust strptime - too lenient e.g 1:2:3 is parsed
      def time_to_seconds(time_string)
        timestamp_regex = /\A([01][0-9]|2[0-3]):([0-5][0-9]):([0-5][0-9])\z/
        matches = timestamp_regex.match(time_string)
        return nil if matches.nil?
        (matches[1].to_i * (60 * 60)) + (matches[2].to_i * 60) + matches[3].to_i
      end

      def parse_boundary(boundary)
        case boundary
        when 'End'
          :end
        when 'Start'
          :start
        else
          nil
        end
      end

    end
  end
end