require_relative "../models/user.rb"

module Authentication
    def register(users)
        print "Nhập username: "
        username = gets.chomp
        if users.any? { |user| user.username == username }
            puts "Đã tồn tại username"
            return
        end

        print "Nhập password: "
        password = gets.chomp

        user = User.new(username, password)
        users << user
        puts "Đăng ký thành công"
    end

    def login(users)
        print "Nhập username: "
        username = gets.chomp
        print "Nhập mật khẩu: "
        password = gets.chomp
        user = users.find { |user| user.username == username && user.password == password }

        if user
            puts "Đăng nhập thành công"
            user
        else
            puts "Tên đăng nhập hoặc mật khẩu không đúng"
            nil
        end            
    end
end
