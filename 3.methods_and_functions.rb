###########################################################
# CHỦ ĐỀ 3: METHODS AND FUNCTIONS TRONG RUBY
###########################################################

# 🧩 1️⃣ Định nghĩa method cơ bản
# Cú pháp:
# def tên_method(tham_số)
#   # thân hàm
#   return giá_trị
# end

def greet(name)
  "Xin chào, #{name}!"
end

puts greet("Thiện")  # => "Xin chào, Thiện!"

###########################################################

# 🧩 2️⃣ Method có giá trị trả về ngầm định
# Ruby tự động trả về kết quả của dòng cuối cùng, 
# không cần viết "return" (trừ khi bạn muốn kết thúc sớm).

def square(n)
  n * n   # kết quả dòng cuối sẽ được return
end

puts square(5)  # => 25

###########################################################

# 🧩 3️⃣ Tham số mặc định (default parameters)

def greet_user(name = "Guest")
  "Hello, #{name}!"
end

puts greet_user         # => "Hello, Guest!"
puts greet_user("Thien")# => "Hello, Thien!"

###########################################################

# 🧩 4️⃣ Tham số không giới hạn (*args)
# Dùng dấu * để gom nhiều đối số thành mảng.

def sum_all(*numbers)
  numbers.sum
end

puts sum_all(1, 2, 3, 4)  # => 10

###########################################################

# 🧩 5️⃣ Keyword arguments
# Cho phép truyền tham số bằng tên, dễ đọc và linh hoạt hơn.

def introduce(name:, age:)
  "Tôi là #{name}, #{age} tuổi."
end

puts introduce(name: "Thien", age: 25)
# => "Tôi là Thien, 25 tuổi."

###########################################################

# 🧩 6️⃣ Return nhiều giá trị
# Ruby có thể trả về nhiều giá trị (dưới dạng mảng).

def stats(a, b)
  sum = a + b
  diff = a - b
  [sum, diff]
end

s, d = stats(10, 4)
puts "Tổng: #{s}, Hiệu: #{d}"  # => Tổng: 14, Hiệu: 6

###########################################################

# 🧩 7️⃣ Scope biến trong method
# Biến được khai báo trong method là local, không truy cập được bên ngoài.

def demo_scope
  x = 10
end

# puts x  # ❌ Lỗi: undefined local variable

###########################################################

# 🧩 8️⃣ Method có thể gọi lồng nhau

def double(n)
  n * 2
end

def triple(n)
  n * 3
end

def double_then_triple(n)
  triple(double(n))
end

puts double_then_triple(2) # => 12

###########################################################

# 🧩 9️⃣ Method với block (yield)
# yield cho phép gọi block được truyền vào method.

def repeat(times)
  times.times { yield }
end

repeat(3) { puts "Hello Ruby!" }
# => In "Hello Ruby!" 3 lần

###########################################################

# 🧩 🔟 Lambda và Proc (Hàm ẩn danh)
# Lambda và Proc là object hàm, giúp truyền hàm như biến.

say_hi = ->(name) { "Hi, #{name}!" }
puts say_hi.call("Thien")  # => "Hi, Thien!"

def execute_block(block)
  puts block.call("Ruby")
end

execute_block(say_hi)  # => "Hi, Ruby!"

###########################################################

# ✅ Tổng kết nhanh:
# - def: định nghĩa method
# - return: có thể bỏ, Ruby tự return dòng cuối
# - *args: gom nhiều tham số
# - name:, age:: keyword arguments
# - yield: thực thi block
# - lambda/proc: hàm ẩn danh
###########################################################
