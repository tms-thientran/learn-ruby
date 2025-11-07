require_relative "./transaction_service.rb"

include TransactionService

module BankService
    def show_menu(user)
        loop do
            puts "\n===== Xin chào, #{user.username} ====="
            puts "1. Xem số dư"
            puts "2. Nạp tiền"
            puts "3. Rút tiền"
            puts "4. Lịch sử giao dịch"
            puts "5. Đăng xuất"
            print "Chọn: "

            case gets.chomp.to_i
            when 1
                puts "Số dư hiện tại là: #{user.balance}"
            when 2
                deposit(user)
            when 3
                withdraw(user)
            when 4
                show_history(user)
            when 5
                puts "Đăng xuất thành công!"
                break
            else 
                puts "Không hợp lệ vui lòng nhập lại"
            end
        end
    end
end
