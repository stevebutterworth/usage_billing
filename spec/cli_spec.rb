module UsageBilling
  RSpec.describe "./bin/usage_billing" do
    it "outputs error to stderr if no file given" do
      status = nil
      expect { status = system %(bin/usage_billing) }
        .to output("Usage: bin/usage_billing LOGFILE\n")
        .to_stderr_from_any_process
      expect(status).to be(false)
    end

    it "outputs to stdout with correct bills if simple file opens and valid" do
      status = nil
      expect { status = system %(bin/usage_billing ./spec/fixtures/basic_usage.log) }
        .to output("ALICE99 4 240\nCHARLIE 3 37\n")
        .to_stdout_from_any_process
        .and output("")
        .to_stderr_from_any_process
      expect(status).to be(true)
    end
  end
end
