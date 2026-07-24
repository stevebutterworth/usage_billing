require "usage_billing/usage_log"

module UsageBilling
  RSpec.describe UsageLog do
    it "parses a line to timestamp, name and boundary" do
      log_text = "14:02:03 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to eq([
        UsageLog::Entry.new(
          time_of_day_seconds: 50523,
          user: "ALICE99",
          boundary_marker: :start
        )
      ])
    end

    it "fails to parse an empty string silently" do
      log_text = ""

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end


    it "fails to parse nil text silently" do
      log_text = nil

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse an empty line silently" do
      log_text = "\n"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with a single word" do
      log_text = "this_is_not_valid"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line if it can't find all 3 fields silently" do
      log_text = "14:02:03 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with out of bounds hour silently" do
      log_text = "29:02:03 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with text appended to the bound silently" do
      log_text = "29:02:03 ALICE99 Started"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with out of bounds minute silently" do
      log_text = "14:66:03 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with out of bounds second silently" do
      log_text = "14:02:99 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with single digit second silently" do
      log_text = "1:2:3 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with missing seconds" do
      log_text = "14:02 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with trailing characters on timestamp" do
      log_text = "14:02:45hello ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with missing minutes and seconds" do
      log_text = "14 ALICE99 Start"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "fails to parse a line with invalid boundary silently" do
      log_text = "14:02:03 ALICE99 Middle"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end
    it "fails to parse a line with a username that is not alphanumeric silently" do
      log_text = "14:02:03 ALICE-99 End"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to be_empty
    end

    it "successfully parses line with irregular whitespace" do
      log_text = "14:02:03    ALICE99\t\t\tStart\n"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to eq([
        UsageLog::Entry.new(time_of_day_seconds: 50523, user: "ALICE99", boundary_marker: :start)
      ])
    end

    it "succesffully parses a line with extra data as long as first 3 fields are present and correct" do
      log_text = "14:02:03 ALICE99 Start alsorts of extra stuff"

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to eq([
        UsageLog::Entry.new(time_of_day_seconds: 50523, user: "ALICE99", boundary_marker: :start)
      ])
    end

    it "should parse multiple lines" do
      log_text = [
        "14:02:03 ALICE99 Start",
        "14:02:05 ALICE99 End"
      ].join("\n")

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries).to eq([
        UsageLog::Entry.new(time_of_day_seconds: 50523, user: "ALICE99", boundary_marker: :start),
        UsageLog::Entry.new(time_of_day_seconds: 50525, user: "ALICE99", boundary_marker: :end)
      ])
    end

    it "should return log bounds" do
      log_text = [
        "14:02:03 ALICE99 Start",
        "14:02:05 ALICE99 End"
      ].join("\n")

      usage_log = described_class.parse(log_text)

      expect(usage_log.log_window).to eq(50523..50525)
    end

    it "should return no log bound with empty line" do
      log_text = "\n"

      usage_log = described_class.parse(log_text)

      expect(usage_log.log_window).to eq(nil)
    end

    it "group user sessions in useer alphabetical order with entries_by_user" do
      log_text = [
        "14:02:03 DENNIS Start",
        "14:02:05 DENNIS End",
        "14:04:03 ALICE99 Start",
        "14:05:05 ALICE99 End"
      ].join("\n")

      usage_log = described_class.parse(log_text)

      expect(usage_log.entries_by_user).to eq({
        "ALICE99" => [
          UsageLog::Entry.new(time_of_day_seconds: 50643, user: "ALICE99", boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50705, user: "ALICE99", boundary_marker: :end)
        ],
        "DENNIS" => [
          UsageLog::Entry.new(time_of_day_seconds: 50523, user: "DENNIS", boundary_marker: :start),
          UsageLog::Entry.new(time_of_day_seconds: 50525, user: "DENNIS", boundary_marker: :end)
        ]
      })
    end
  end
end
