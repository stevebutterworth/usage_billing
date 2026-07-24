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

    describe ".run" do

      it "exits and writes to stderr when run has empty args" do
        status = Application.run([], output: output, error: error)

        expect(error.string).to eq("Usage: bin/usage_billing LOGFILE\n")
        expect(output.string).to be_empty
        expect(status).to eq(1)
      end
      it "exits and writes to stderr when run has more than one 1 arg" do
        status = Application.run(["file.log", "file2.log"], output: output, error: error)

        expect(error.string).to eq("Usage: bin/usage_billing LOGFILE\n")
        expect(output.string).to be_empty
        expect(status).to eq(1)
      end
      it "exits and writes to stderr when the passed in file name cannot be read" do
        status = Application.run(["file.log"], output: output, error: error)

        expect(error.string).to match(/No such file or directory/)
        expect(output.string).to be_empty
        expect(status).to eq(1)
      end

      it "reads an empty file successfully but has no output" do
        status = Application.run(["./spec/fixtures/empty.log"], output: output, error: error)

        expect(error.string).to be_empty
        expect(output.string).to be_empty
        expect(status).to eq(0)
      end
      it "reads a clean file successfully and prints the user bills" do
        status = Application.run(["./spec/fixtures/basic_usage.log"], output: output, error: error)

        expect(error.string).to be_empty
        expect(output.string).to eq(to_output([
          "ALICE99 4 240",
          "CHARLIE 3 37"
        ]))
        expect(status).to eq(0)
      end

      it "reads a file with valid and invalid lines successfully and prints the user bills" do
        status = Application.run(["./spec/fixtures/dirty_usage.log"], output: output, error: error)

        expect(error.string).to be_empty
        expect(output.string).to eq(to_output([
          "ALICE99 4 240",
          "CHARLIE 3 37"
        ]))
        expect(status).to eq(0)
      end

      it "reads a busy file successfully and prints the user bills" do
        status = Application.run(["./spec/fixtures/busy_usage.log"], output: output, error: error)

        expect(error.string).to be_empty
        expect(output.string).to eq(to_output([
          "ALICE99 6 11272",
          "BORIS 1 2",
          "CHARLIE 3 19763",
          "DENNIS 3 21938",
          "JEREMYHASALONGNAME 1 14522"
        ]))
        expect(status).to eq(0)
      end
    end
  end
end
