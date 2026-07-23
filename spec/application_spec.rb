# frozen_string_literal: true

require "usage_billing"
require "stringio"

module UsageBilling
  RSpec.describe Application do
    let(:output) { StringIO.new }
    let(:error) { StringIO.new }

    def to_output(lines)
      lines.join("\n") + "\n"
    end

    it "exits and writes to stderr if run has empty args" do
      Application.run([], output: output, error: error)

      expect(error.string).to eq("Usage: bin/usage_billing LOGFILE\n")
      expect(output.string).to be_empty
    end
    it "exits and wrties to stderr if run has more than one 1 args" do
      Application.run(["file.log", "file2.log"], output: output, error: error)

      expect(error.string).to eq("Usage: bin/usage_billing LOGFILE\n")
      expect(output.string).to be_empty
    end
    it "exits and writes to stderr if the passed in file name cannot be read" do
      Application.run(["file.log"], output: output, error: error)

      expect(error.string).to eq("No such file or directory @ rb_sysopen - file.log\n")
      expect(output.string).to be_empty
    end

    it "reads an empty file successfully but have no output" do
      Application.run(["./spec/fixtures/empty.log"], output: output, error: error)

      expect(error.string).to be_empty
      expect(output.string).to be_empty
    end
    it "reads a clean file successfully and print the user bills" do
      Application.run(["./spec/fixtures/basic_usage.log"], output: output, error: error)

      expect(error.string).to be_empty
      expect(output.string).to eq(to_output([
        "ALICE99 4 240",
        "CHARLIE 3 37"
      ]))
    end

    it "reads a dirty file successfully and print the user bills" do
      Application.run(["./spec/fixtures/dirty_usage.log"], output: output, error: error)

      expect(error.string).to be_empty
      expect(output.string).to eq(to_output([
        "ALICE99 4 240",
        "CHARLIE 3 37"
      ]))
    end

    it "reads a busy file successfully and prints the user bills" do
      Application.run(["./spec/fixtures/busy_usage.log"], output: output, error: error)

      expect(error.string).to be_empty
      expect(output.string).to eq(to_output([
        "ALICE99 6 11272",
        "BORIS 1 2",
        "CHARLIE 3 19763",
        "DENNIS 3 21938",
        "JEREMYHASALONGNAME 1 14522"
      ]))
    end
  end
end
