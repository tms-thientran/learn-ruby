require_relative "./services/authentication.rb"
require_relative "./services/bank_service.rb"

include Authentication
include BankService

puts "ATM project"

users = []

loop do
    puts "=====ATM banking====="
    puts "Vui lòng chọn các mục sau"
    puts "1. Đăng ký"
    puts "2. Đăng nhập"
    puts "3. Thoát"
    print "Chọn: "

    case gets.chomp.to_i
    when 1
        register(users)
    when 2
        user = login(users)

        show_menu(user) if user
    when 3
        puts "Tạm biệt, hẹn gặp lại"
        break 
    else
        puts "Không hợp lệ, vui lòng thử lại"
    end
end
