###########################################################
# CHỦ ĐỀ 5: MODULES AND MIXINS
###########################################################

# 🧩 1️⃣ Module là gì?
# Module là nơi nhóm các method, constant hoặc logic dùng chung.
# Dùng để chia sẻ code giữa nhiều class (giống "mixin").

module Greetable
  def greet
    "Xin chào!"
  end
end

# 🧩 2️⃣ include vs extend
# include: thêm method vào instance
# extend: thêm method vào class

class Person
  include Greetable   # instance method
end

class Admin
  extend Greetable    # class method
end

puts Person.new.greet   # => "Xin chào!"
puts Admin.greet        # => "Xin chào!"

###########################################################

# 🧩 3️⃣ Module chứa hằng số và method riêng

module MathTool
  PI = 3.14159

  def self.square(n)
    n * n
  end
end

puts MathTool::PI          # => 3.14159
puts MathTool.square(5)    # => 25

###########################################################

# 🧩 4️⃣ Mixin thực tế
# Khi cần chia sẻ logic chung mà không dùng kế thừa.

module Loggable
  def log(msg)
    puts "[#{Time.now}] #{msg}"
  end
end

class Order
  include Loggable

  def checkout
    log("Checkout thành công!")
  end
end

Order.new.checkout
# => [2025-11-06 ...] Checkout thành công!

###########################################################

# ✅ Tổng kết:
# - module: nhóm logic tái sử dụng
# - include: thêm method vào instance
# - extend: thêm method vào class
# - :: truy cập constant trong module
###########################################################
