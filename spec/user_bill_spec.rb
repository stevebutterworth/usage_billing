require "usage_billing/user_bill"

module UsageBilling

  RSpec.describe UserBill do
    it "returns 0 for total duration when no sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [])

      expect(bill.total_duration).to eq(0)
    end

    it "returns 0 for total duration when only nil sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [nil, nil])

      expect(bill.total_duration).to eq(0)
    end

    it "returns session duration for total duration when 1 session" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        Session.new(start_at: 50623, end_at: 50823)
      ])

      expect(bill.total_duration).to eq(200)
    end

    it "returns summed session durations when for total duration for a array of sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        Session.new(start_at: 50623, end_at: 50823),
        Session.new(start_at: 50624, end_at: 50626)
      ])

      expect(bill.total_duration).to eq(202)
    end

    it "returns 0 for session count when no sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [])

      expect(bill.session_count).to eq(0)
    end

    it "returns 0 for session count when ony nil sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [nil, nil])

      expect(bill.session_count).to eq(0)
    end

    it "returns 1 for session count when 1 session" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        Session.new(start_at: 50723, end_at: 50924)
      ])

      expect(bill.session_count).to eq(1)
    end

    it "returns 2 for session count when 2 sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        Session.new(start_at: 50723, end_at: 50924),
        Session.new(start_at: 50723, end_at: 50924)
      ])

      expect(bill.session_count).to eq(2)
    end

    it "returns 0 duration and 0 sessions for bill with no sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [])

      expect(bill.to_s).to eq("ALICE99 0 0")
    end

    it "returns empty string if no user when stringified" do
      bill = UserBill.new(user: '', sessions: [])

      expect(bill.to_s).to eq("")
    end

    it "returns valid line with zero durartion and zero sessions if only nil sessions" do
      bill = UserBill.new(user: 'ALICE99', sessions: [nil])

      expect(bill.to_s).to eq("ALICE99 0 0")
    end

    it "returns still return the right bill if session includes nil values" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        nil,
        Session.new(start_at: 50723, end_at: 50924),
      ])

      expect(bill.to_s).to eq("ALICE99 1 201")
    end

    it "returns 2 sessions with duration summed when 2 valid sessions given" do
      bill = UserBill.new(user: 'ALICE99', sessions: [
        Session.new(start_at: 50623, end_at: 50823),
        Session.new(start_at: 50723, end_at: 50924)
      ])

      expect(bill.to_s).to eq("ALICE99 2 401")
    end

  end

end