require_relative '../services/transaction_service.rb'

class Account
  attr_reader :balance, :history

  def initialize
    @balance = 0
    @history = []
    @transaction_service = TransactionService.new(@history)
  end

  def deposit(amount)
    return puts "Số tiền nhập vào phải lớn hơn 0" if amount <= 0
    @balance += amount
    @transaction_service.record('DEPOSIT', amount)
    
    puts "Nạp #{amount} thành công. Số dư: #{@balance}"
  end

  def withdraw(amount)
    return puts "Số tiền nạp vào phải lớn hơn 0" if amount <= 0
    return puts "Số dư không đủ" if amount > @balance

    @balance -= amount
    @transaction_service.record('WITHDRAW', amount) do |tx|
      puts "✅ Giao dịch: #{tx.type} #{tx.amount} lúc #{tx.time}"
    end
    
    puts "Rút #{amount} thành công. Số dư: #{@balance}"
  end

  def display_history
    @transaction_service.display
  end
end
