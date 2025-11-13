class TransactionService
    def initialize()
      @transactions = [] 
    end

    def init_transaction(type, amount, note = nil)
        transaction = Transaction.new(type, amount, note)

        yield(transaction) if block_given?

        @transactions << transaction

        transaction
    end

    def show_history
        if @transactions.empty?
            puts "Không có giao dịch nào"
        else
            @transactions.each_with_index do |transaction, i|
                puts "#{i+1}. #{transaction.display}"
            end
        end
    end
end
