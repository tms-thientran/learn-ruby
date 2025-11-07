require_relative "./models/user.rb"
require_relative "./models/account.rb"

class ATM
    def initialize
        @users = []
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

            @current_user.account.deposit(amount)
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

        if @users.any? { |user| user.username == username }
            puts "Username đã tồn tại"
            return
        end

        print "Nhập password: "
        password = gets.chomp

        @current_user = User.new(username, password)
        @users << @current_user

        puts "Đăng ký thành công"
    end

    def login
        print "Nhập username: "
        username = gets.chomp

        print "Nhập password: "
        password = gets.chomp
        user = @users.find { |user| user.username == username && user.password == password }
        if !user 
            puts "Username hoặc password khôgn đúng"
            return
        end

        @current_user = user

        puts "Đăng nhập thành công"
    end
end

ATM.new.start
