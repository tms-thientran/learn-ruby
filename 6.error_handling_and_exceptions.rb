

###########################################################
# CHỦ ĐỀ 6: ERROR HANDLING AND EXCEPTIONS
###########################################################

# 🧩 1️⃣ Bắt lỗi cơ bản với begin-rescue-end

begin
  puts 10 / 0
rescue ZeroDivisionError => e
  puts "Lỗi: #{e.message}"
end

# => "Lỗi: divided by 0"

###########################################################

# 🧩 2️⃣ Nhiều loại lỗi

begin
  File.read("khong_ton_tai.txt")
rescue ZeroDivisionError
  puts "Lỗi chia 0"
rescue Errno::ENOENT
  puts "File không tồn tại"
rescue => e
  puts "Lỗi khác: #{e.class}"
end

###########################################################

# 🧩 3️⃣ ensure — luôn chạy (dù có lỗi hay không)

begin
  puts "Đang đọc file..."
  raise "Fake error"
rescue
  puts "Đã bắt lỗi!"
ensure
  puts "Đóng file (luôn chạy)"
end

###########################################################

# 🧩 4️⃣ raise — tự tạo lỗi

def divide(a, b)
  raise ArgumentError, "b không được bằng 0" if b == 0
  a / b
end

puts divide(10, 2)
# puts divide(10, 0)  # => ArgumentError

###########################################################

# 🧩 5️⃣ Custom exception

class InvalidAgeError < StandardError; end

def register(age)
  raise InvalidAgeError, "Tuổi phải >= 18" if age < 18
  puts "Đăng ký thành công!"
end

begin
  register(15)
rescue InvalidAgeError => e
  puts e.message
end

###########################################################

# ✅ Tổng kết:
# - begin ... rescue ... end: bắt lỗi
# - ensure: luôn chạy (giống finally)
# - raise: tự phát sinh lỗi
# - Custom Error < StandardError
###########################################################
