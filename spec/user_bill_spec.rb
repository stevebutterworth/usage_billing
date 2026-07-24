require "usage_billing/user_bill"

module UsageBilling
  RSpec.describe UserBill do
    describe "#total_duration" do
      it "returns 0 for when no sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [])

        expect(bill.total_duration).to eq(0)
      end

      it "returns 0 for when only nil sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [nil, nil])

        expect(bill.total_duration).to eq(0)
      end

      it "returns session duration when 1 session" do
        bill = UserBill.new(user: "ALICE99", sessions: [
          Session.new(start_at: 50623, end_at: 50823)
        ])

        expect(bill.total_duration).to eq(200)
      end

      it "returns summed session durations for multiple sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [
          Session.new(start_at: 50623, end_at: 50823),
          Session.new(start_at: 50624, end_at: 50626)
        ])

        expect(bill.total_duration).to eq(202)
      end
    end

    describe "#session_count" do
      it "returns 0 when no sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [])

        expect(bill.session_count).to eq(0)
      end
      it "returns 0 when ony nil sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [nil, nil])

        expect(bill.session_count).to eq(0)
      end

      it "returns array count when multiple valid sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [
          Session.new(start_at: 50723, end_at: 50924),
          Session.new(start_at: 50723, end_at: 50924)
        ])

        expect(bill.session_count).to eq(2)
      end
    end
    describe "#to_s" do
      it "returns 0 duration and 0 sessions for bill with no sessions" do
        bill = UserBill.new(user: "ALICE99", sessions: [])

        expect(bill.to_s).to eq("ALICE99 0 0")
      end

      it "returns empty string when no user" do
        bill = UserBill.new(user: "", sessions: [])

        expect(bill.to_s).to eq("")
      end

      it "returns session count and total duration when mutiple sessions given" do
        bill = UserBill.new(user: "ALICE99", sessions: [
          Session.new(start_at: 50623, end_at: 50823),
          Session.new(start_at: 50723, end_at: 50924)
        ])

        expect(bill.to_s).to eq("ALICE99 2 401")
      end
    end
  end
end
