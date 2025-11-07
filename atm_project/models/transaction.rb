class Transaction
    def initialize(type, amount)
        @type = type
        @amount = amount
        @time = Time.now
    end
end
