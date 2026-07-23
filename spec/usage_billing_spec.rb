module UsageBilling

  RSpec.describe "./bin/usage_billing" do

    it "outputs error to stderr if no file given" do
      expect { system %(bin/usage_billing) }
        .to output("Usage: bin/usage_billing LOGFILE\n")
        .to_stderr_from_any_process
    end

    it "outputs error to stderr if bad file path" do
      expect { system %(bin/usage_billing bad_file.log) }
        .to output("No such file or directory @ rb_sysopen - bad_file.log\n")
        .to_stderr_from_any_process
    end

    it "outputs to stdout with correct bills if simple file opens and valid" do
      expect { system %(bin/usage_billing ./spec/fixtures/basic_usage.log) }
        .to output("ALICE99 4 240\nCHARLIE 3 37\n")
        .to_stdout_from_any_process
    end

    it "has no output when passed an empty file" do
      expect { system %(bin/usage_billing ./spec/fixtures/empty.log) }
        .to output("")
        .to_stdout_from_any_process
    end
    it "has no output when passed an invalid file" do
      expect { system %(bin/usage_billing ./spec/fixtures/bad.log) }
        .to output("")
        .to_stdout_from_any_process
    end

  end

end