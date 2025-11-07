class Transaction
    attr_reader :type, :amount, :time

    def initialize(type, amount, note = nil)
        @type = type
        @amount = amount
        @time = Time.now
        @note = note
    end

    def info
        "#{time.strftime("%Y-%m-%d %H:%M:%S")} - #{type.upcase}: #{amount}"
    end
end
