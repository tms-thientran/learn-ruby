##############################################
# 2. Control Structures (Conditionals & Loops)
##############################################

# 🎯 Mục tiêu:
# - Hiểu và sử dụng các cấu trúc điều khiển trong Ruby:
#   + if / elsif / else
#   + unless
#   + case / when
#   + while / until
#   + for / each / times / upto / downto
#   + break, next, redo

# ------------------------------
# 1️⃣ IF / ELSIF / ELSE
# ------------------------------
age = 18

if age < 13
  puts "Trẻ em"
elsif age < 18
  puts "Thiếu niên"
else
  puts "Người lớn"
end

# 👉 if có thể viết 1 dòng:
puts "Đủ tuổi" if age >= 18


# ------------------------------
# 2️⃣ UNLESS (ngược với IF)
# ------------------------------
is_admin = false
unless is_admin
  puts "Truy cập bị từ chối"
end
# hoặc viết gọn:
puts "Chỉ dành cho admin" unless is_admin


# ------------------------------
# 3️⃣ CASE / WHEN (giống switch)
# ------------------------------
day = "Mon"

case day
when "Mon"
  puts "Đầu tuần"
when "Fri"
  puts "Cuối tuần tới"
else
  puts "Giữa tuần"
end


# ------------------------------
# 4️⃣ Vòng lặp WHILE / UNTIL
# ------------------------------
count = 0
while count < 3
  puts "Đếm: #{count}"
  count += 1
end

# until = lặp cho đến khi điều kiện đúng
count = 0
until count == 3
  puts "Đếm (until): #{count}"
  count += 1
end


# ------------------------------
# 5️⃣ FOR / EACH
# ------------------------------
for i in 1..3
  puts "for: #{i}"
end

[10, 20, 30].each do |num|
  puts "each: #{num}"
end


# ------------------------------
# 6️⃣ TIMES / Upto / Downto
# ------------------------------
3.times { |i| puts "times: #{i}" }

1.upto(3) { |i| puts "upto: #{i}" }

3.downto(1) { |i| puts "downto: #{i}" }


# ------------------------------
# 7️⃣ BREAK / NEXT 
# ------------------------------
(1..5).each do |n|
  break if n == 4
  next if n.even?
  puts "Số lẻ: #{n}"
end
