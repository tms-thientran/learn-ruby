module TransactionService
    # puts "2. Nạp tiền"
    # puts "3. Rút tiền"
    # puts "4. Lịch sử giao dịch"

    def deposit(user)
        print "Vui lòng nhập số tiền cần nạp: "
        amount = gets.chomp.to_i

        if amount <= 0
            puts "Số tiền nạp phải lớn hơn 0"
            return
        else
            user.balance += amount
            user.history << { type: "DEPOSIT", amount: amount, time: Time.now }
            puts "Nạp tiền thành công"
        end
    end

    def withdraw(user)
        print "Vui lòng nhập số tiền cần rút: "
        amount = gets.chomp.to_i

        if amount <= 0 
            puts "Số tiền rút lớn hơn 0"
        elsif amount > user.balance
            puts "Số dư không đủ"
        else
            user.balance -= amount
            user.history << { type: "WITHDRAW", amount: amount, time: Time.now }
            puts "Rút tiền thành công #{amount}"
        end
    end

    def show_history(user)
        if user.history.empty?
            puts "Không có lịch sử giao dịch"
        else 
            user.history.each do |h|
                puts "#{h[:time].strftime("%H:%M:%S")} | #{h[:type].upcase} | #{h[:amount]}"
            end
        end
    end
end
