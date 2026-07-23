# Usage Billing CLI

## Description
A small Ruby command-line application that calculates user bills for a hosted application provider.

The applicatins takes a raw log of session starts and ends and calculates total session durations for each user.
* Parses cronoligical log entries ignoring lines that do not conform to the form `HH:MM:SS USERNAME Start|End`
* Supports overlalping sessions
* Reports total usage outpiut to stdout. 1 line per user in format `USERNAME SESSION_COUNT TOTAL_DURATION`

## Requirements
* Ruby 4.0.6
* Bundler

## Installation
```sh
bundle install
chmod +x bin/usage_billing
```

## Usage

Given the provided example at spec/fixtures/basic_usage.log provides
```text
14:02:03 ALICE99 Start
14:02:05 CHARLIE End
14:02:34 ALICE99 End
14:02:58 ALICE99 Start
14:03:02 CHARLIE Start
14:03:33 ALICE99 Start
14:03:35 ALICE99 End
14:03:37 CHARLIE End
14:04:05 ALICE99 End
14:04:23 ALICE99 End
14:04:41 CHARLIE Start
```

```sh
bin/usage_billing spec/fixtures/basic_usage.log
ALICE99 4 240
CHARLIE 3 37
```

## Assumptions
1. Log is assumed to be in chronological order
2. Multiple sessions may be active at once
3. A user session with an unmatched start will assume the last log entry time as the session end time
4. A user session with an unmatched end will assume the start log entry time as the session start time
5. Zero duration sessions are still reported
6. Timestamps must be in the format HH:MM:SS
7. Usernames must be alphanumeric
7. Any type or amount of whitespace between or around log entries is valid
8. All log entries are from within a single day
9. Only 1 log file can be passed in
10. Files with no valid entries results in a successful but empty response

## Testing
```sh
bundle exec rspec
```

## Architecture
* `UsageBilling` is the project namespace
* `Application` is the main entry point handling IO and orchestrating the flow
* `UsageLog` parses the log file text and exposes its entries and log time window
* `Session` represents a billable period and calculates its duration

## Error behaviour
The appication exits with none-zero status if:
* No file name is given
* The file cannot be found or read