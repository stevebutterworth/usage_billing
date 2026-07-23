# frozen_string_literal: true

module UsageBilling

  UserBill = Data.define(:user, :sessions) do

    def total_duration = sessions.compact.sum(&:duration)

    def session_count = sessions.compact.count

    def to_s
      return "" if user.empty?
      "#{user} #{session_count} #{total_duration}"
    end

  end

end