require_relative '../services/transaction_service.rb'

class Account
  attr_reader :balance, :history

  def initialize
    @balance = 0
    @history = []
    @transaction_service = TransactionService.new(@history)
    @fee_caculator = -> (amount) { (amount * 0.02).round(2) }
  end

  def set_fee_caculator(&block)
    @fee_caculator = block if block_given?
  end

  def deposit(amount)
    raise ArgumentError, "Số tiền phải lớn hơn 0" if amount <= 0

    bonus = block_given? ? yield(amount) : 0
    total = amount + bonus

    @balance += amount
    @transaction_service.record('DEPOSIT', total, "Thưởng thêm #{bonus}") do |tx|
      puts "✅ Giao dịch: #{tx.type} #{tx.amount} lúc #{tx.time}"
    end
    
    puts "💰 Nạp #{amount} (+#{bonus}) thành công. Số dư hiện tại: #{@balance}"
  rescue ArgumentError => e
    puts "X #{e.message}"
  ensure
    puts "Kết thúc nạp tiền. \n\n"
  end

  def withdraw(amount)
    raise ArgumentError, "Số tiền phải lớn hơn 0" if amount <= 0
    fee = @fee_caculator.call(amount)
    total = amount + fee

    if total > @balance
      raise StandardError, "Số dư không đủ để rút (bao gồm phí #{fee})"
    end

    @balance -= total
    @transaction_service.record('WITHDRAW', total, "phí #{fee}") do |tx|
      puts "💸 Rút #{amount}, phí #{fee}, lúc #{tx.time}"
    end
    
    puts "Rút #{amount} thành công. Số dư: #{@balance}"
  rescue => e
    puts "⚠️  Lỗi giao dịch: #{e.message}"
  ensure
    puts "💡 Kết thúc rút tiền.\n\n"
  end

  def display_history
    @transaction_service.display
  end
end
