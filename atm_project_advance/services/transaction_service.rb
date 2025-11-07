require_relative '../models/transaction.rb'

class TransactionService
    def initialize(history)
      @history = history
    end

    def record(type, amount, note = nil)
        tx = Transaction.new(type, amount, note)

        @history << tx
        yield(tx) if block_given?

        tx
    end

    def display
        if @history.empty?
            puts "Chưa có lịch sử giao dịch"
        else
            puts "========= Lịch sử giao dịch ========"
            @history.each { |h| puts h.info }
        end
    end
end
