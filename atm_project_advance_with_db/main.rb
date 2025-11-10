require_relative './autoloader.rb'
require_relative './db/database.rb'

Autoloader.load!('./models')

Database.connection
Database.create_tables

# Database.execute("DELETE FROM accounts")

class ATM
    def initialize
        @current_user = nil
    end

    def start
        loop do
            @current_user ? show_main_menu : show_welcome_menu
        end
    end

    def show_main_menu
        puts "\n=== MENU CHÍNH ==="
        puts "1. Xem số dư"
        puts "2. Nạp tiền"
        puts "3. Rút tiền"
        puts "4. Lịch sử giao dịch"
        puts "5. Đăng xuất"
        print "Chọn: "

        case gets.chomp.to_i
        when 1
            puts "Số dư hiện tại là #{@current_user.account.balance}"
        when 2
            print "Nhập số tiền cần nạp: "
            amount = gets.chomp.to_i

            @current_user.account.deposit(amount) { |amt| amt > 1000 ? (amt * 0.05).round(2) : 0 }
        when 3
            print "Nhập số tiền cần rút: "
            amount1 = gets.chomp.to_i

            @current_user.account.withdraw(amount1)
        when 4
            @current_user.account.display_history
        when 5
            puts "By nhé #{@current_user.username}"
            @current_user = nil
        else
            puts "Nhập vào không hợp lệ, vui lòng thử lại"
        end
    end

    def show_welcome_menu
        puts "\n=== 💳 HỆ THỐNG ATM ==="
        puts "1. Đăng ký"
        puts "2. Đăng nhập"
        puts "3. Thoát"
        print "Chọn: "

        case gets.chomp.to_i
        when 1
            register
        when 2
            login
        when 3
            puts "Chào tạm biệt. Hẹn gặp lại nhé"
            exit
        else
            puts "Nhập vào không hợp lệ, vui lòng thử lại"
        end
    end

    def register
        print "Nhập username: "
        username = gets.chomp

        if User.find_by_username(username)
            puts "Username đã tồn tại"
            return
        end

        print "Nhập password: "
        password = gets.chomp

        user = User.new
        user.username = username
        user.password = password
        user.save

        @current_user = user

        puts "Đăng ký thành công"
    end

    def login
        print "Nhập username: "
        username = gets.chomp

        print "Nhập password: "
        password = gets.chomp

        user = User.find_by_username(username)

        if !user || user.password != password
            puts "Username hoặc password không đúng"
            return
        end

        @current_user = user
        # set_dynamic_fee

        puts "Đăng nhập thành công"
    end

    def set_dynamic_fee()
        @current_user.account.set_fee_calculator do |amount|
            hour = Time.now.hour
            base = 0.02
            extra = (hour >= 20 || hour <= 6) ? 0.01 : 0
            (amount * (base + extra)).round(2)
        end
    end
end

ATM.new.start
