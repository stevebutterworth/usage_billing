# Usage Billing CLI

## Description
A small Ruby command-line application that calculates user bills for a hosted application provider.

The applications takes a raw log of session starts and ends and calculates total session durations for each user.
* Parses chronological log entries ignoring lines that do not begin with format `HH:MM:SS USERNAME Start|End`
* Supports overlapping sessions
* Reports total usage output to stdout. 1 line per user in format `USERNAME SESSION_COUNT TOTAL_DURATION`

## Requirements
* Ruby 4.0.6
* Bundler

## Installation
```sh
git clone https://github.com/stevebutterworth/usage_billing.git
cd usage_billing
bundle install
chmod +x bin/usage_billing
```

## Usage

```sh
$ bin/usage_billing spec/fixtures/basic_usage.log
ALICE99 4 240
CHARLIE 3 37
```

## Assumptions
1. Log is given in chronological order
2. Multiple sessions may be active at once
3. A user session with an unmatched start will use the last log entry time as the session end time
4. A user session with an unmatched end will use the first log entry time as the session start time
5. Zero duration sessions are still reported
6. Timestamps must be in the format HH:MM:SS
7. Any type or amount of whitespace between or around log entries is valid
8. All log entries are from within a single day
9. Only 1 log file can be passed in
10. Files with no valid entries results in a successful but empty response
11. Any extra text on a line after valid log fields (followed by whitespace) is ignored and line parses successfully
12. Bill reporting is best served in alphabetical order

## Testing
Full unit test suite including smoke tests. Also includes standardrb for linting and formatting. The Github workflow backed CI runs Rake.
```sh
bundle exec rspec
bundle exec rake
```

## Architecture
* `UsageBilling` is the project namespace
* `Application` is the main entry point handling IO and orchestrating the flow
* `UsageLog` parses the log file text and exposes its entries and log time window
* `Session` represents a billable period and calculates its duration
* `UserBill` is responsible for providing a users total duration and session count

## Error behaviour
The appication exits with none-zero status if:
* No file name is given
* The file cannot be found or read