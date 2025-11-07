
###########################################################
# CHỦ ĐỀ 7: FILE HANDLING AND IO OPERATIONS
###########################################################

# 🧩 1️⃣ Ghi file (write)

File.open("data.txt", "w") do |f|
  f.puts "Xin chào Ruby!"
  f.puts "Học file handling"
end
# => Tạo file "data.txt" với 2 dòng

###########################################################

# 🧩 2️⃣ Đọc file (read)

content = File.read("data.txt")
puts content
# => "Xin chào Ruby!\nHọc file handling\n"

###########################################################

# 🧩 3️⃣ Ghi thêm vào cuối file (append)

File.open("data.txt", "a") do |f|
  f.puts "Dòng mới thêm vào."
end

###########################################################

# 🧩 4️⃣ Kiểm tra sự tồn tại

puts File.exist?("data.txt")  # => true
puts File.directory?(".")     # => true

###########################################################

# 🧩 5️⃣ Xoá file hoặc đổi tên

# File.delete("data.txt")
# File.rename("data.txt", "new_data.txt")

###########################################################

# 🧩 6️⃣ Đọc file dòng-by-dòng (hiệu quả với file lớn)

File.foreach("data.txt") do |line|
  puts ">> #{line.chomp}"
end

###########################################################

# 🧩 7️⃣ Nhập/xuất dữ liệu từ bàn phím

# print "Nhập tên: "
# name = gets.chomp
# puts "Xin chào, #{name}!"

###########################################################

# ✅ Tổng kết:
# - File.open(path, mode) {...}
# - "r": đọc, "w": ghi mới, "a": ghi thêm
# - File.read, File.write: nhanh gọn
# - File.exist?, File.delete, File.rename
# - gets / puts / print: IO với console
###########################################################
