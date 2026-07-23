require "usage_billing/usage_log"
require "usage_billing/session"

module UsageBilling

  RSpec.describe Session do

    describe ".build_all" do

      it "returns no sessions with nil entries" do
        sessions = Session.build_all(entries: nil, log_window: (1..86399))

        expect(sessions).to be_empty
      end

      it "returns no sessions with empty entries" do
        sessions = Session.build_all(entries: [], log_window: (1..86399))

        expect(sessions).to be_empty
      end

      it "returns no sessions when no log window" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: nil)

        expect(sessions).to be_empty
      end

      it "returns no sessions when endless log window" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: (1..))

        expect(sessions).to be_empty
      end

      it "returns no sessions when fully unbounded log window" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: (nil..nil))

        expect(sessions).to be_empty
      end

      it "returns no sessions when start is after end" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: (2..1))

        expect(sessions).to be_empty
      end

      it "returns a single session when it has a start and end" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50723, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (1..86399))

        expect(sessions).to match([
          have_attributes(start_at: 50523, end_at: 50723)
        ])
      end

      it "returns a single session using log bounds for start when it has an end only" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50000, end_at: 50623)
        ])
      end

      it "returns a session if its a single start entry with same time as last log entry" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..50623))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50623)
        ])
      end

      it "returns a sessions if its a single end entry with same time as first log entry" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50623..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50623)
        ])
      end

      it "returns sessions with zero duration" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50623..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50623)
        ])
      end

      it "returns a single session using log bounds for end when it has a start only" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 60000)
        ])
      end

      it "returns 2 session when we have 3 records, 2 starts and 1 end" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50723, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50823, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50823),
          Session.new(start_at: 50723, end_at: 60000)
        ])
      end

      it "returns 2 session when we have 4 records, 2 starts and 2 end" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50723, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50823, user: 'ALICE99', boundary_marker: :end),
          UsageLog::Entry.new(time_of_day_seconds: 50923, user: 'ALICE99', boundary_marker: :end)
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50823),
          Session.new(start_at: 50723, end_at: 50923)
        ])
      end

      it "does not care about user, its single responsibility is sessions" do
        entries = [
          UsageLog::Entry.new(time_of_day_seconds: 50623, user: 'ALICE99', boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50723, user: 'BOB66', boundary_marker: :end),
        ]

        sessions = Session.build_all(entries: entries, log_window: (50000..60000))

        expect(sessions).to eq([
          Session.new(start_at: 50623, end_at: 50723),
        ])
      end

    end

    it "is invalid if it has no start" do
      session = Session.new(start_at: nil, end_at: 1)
      expect(session.valid?).to be false
    end

    it "is invalid if it has no end" do
      session = Session.new(start_at: 1, end_at: nil)
      expect(session.valid?).to be false
    end

    it "is invalid if it has an end earlier than a start" do
      session = Session.new(start_at: 2, end_at: 1)
      expect(session.valid?).to be false
    end

    it "is invalid if the start and end time are equal" do
      session = Session.new(start_at: 2, end_at: 2)
      expect(session.valid?).to be true
    end

    it "is valid when start is lower than end" do
      session = Session.new(start_at: 1, end_at: 5)
      expect(session.valid?).to be true
    end

    it "has a nil duration when invalid" do
      session = Session.new(start_at: 2, end_at: 1)
      expect(session.duration).to be_nil
    end

    it "calculates duration when sessions is valid" do
      session = Session.new(start_at: 1, end_at: 5)
      expect(session.duration).to eq(4)
    end
  end
end
