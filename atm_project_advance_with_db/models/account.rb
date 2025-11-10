require_relative 'application_record'

class Account
  include ApplicationRecord
  columns :id, :user_id, :balance

  attr_accessor :id, :user_id, :balance

  def initialize(user_id: nil)
    @user_id = user_id
    @balance ||= 0
    @transaction = Transaction.new(self)
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
    save
    @transaction.record('DEPOSIT', total, "Thưởng thêm #{bonus}") { puts "Đã nạp tiền" }
    
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
    save
    @transaction.record('WITHDRAW', total, "phí #{fee}")
    
    puts "Rút #{amount} thành công. Số dư: #{@balance}"
  rescue => e
    puts "⚠️  Lỗi giao dịch: #{e.message}"
  ensure
    puts "💡 Kết thúc rút tiền.\n\n"
  end

  def display_history
    puts "\n📜 Lịch sử giao dịch:"
    transactions = @transaction.show_history

    if transactions.empty?
      puts "Chưa có giao dịch nào."
    else
      transactions.each do |t|
        puts " - [#{t[:created_at]}] #{t[:type]}: #{t[:amount]} (#{t[:note]})"
      end
    end
  end
end
