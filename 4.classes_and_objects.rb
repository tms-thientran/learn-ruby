###########################################################
# CHỦ ĐỀ 4: CLASSES AND OBJECTS TRONG RUBY
###########################################################

# 🧩 1️⃣ Class cơ bản
# Ruby là ngôn ngữ hướng đối tượng, mọi thứ đều là object.
# Dùng từ khóa `class` để định nghĩa một lớp (class).

class Person
end

p1 = Person.new
puts p1.class  # => Person

###########################################################

# 🧩 2️⃣ Khởi tạo với initialize
# Khi gọi `.new`, Ruby sẽ tự động gọi hàm `initialize` bên trong class.

class Person
  def initialize(name, age)
    @name = name      # biến instance
    @age = age
  end

  def info
    "Tên: #{@name}, Tuổi: #{@age}"
  end
end

person = Person.new("Thiện", 25)
puts person.info
# => "Tên: Thiện, Tuổi: 25"

###########################################################

# 🧩 3️⃣ Instance variables (`@`)
# Mỗi object có biến riêng biệt. Các biến instance bắt đầu bằng `@`.

p1 = Person.new("Alice", 20)
p2 = Person.new("Bob", 30)
puts p1.info  # => "Tên: Alice, Tuổi: 20"
puts p2.info  # => "Tên: Bob, Tuổi: 30"

###########################################################

# 🧩 4️⃣ Getter và Setter (truy cập thuộc tính)
# Dùng attr_reader, attr_writer, attr_accessor để ngắn gọn hơn.

class User
  attr_accessor :name, :email
end

u = User.new
u.name = "Thien"
u.email = "thien@example.com"
puts "#{u.name} - #{u.email}"

###########################################################

# 🧩 5️⃣ Phân biệt instance method và class method

class MathHelper
  def square(n)        # instance method
    n * n
  end

  def self.pi          # class method (dùng self.)
    3.14159
  end
end

m = MathHelper.new
puts m.square(3)      # => 9
puts MathHelper.pi    # => 3.14159

###########################################################

# 🧩 6️⃣ Biến class @@ và method class
# @@ dùng để chia sẻ giá trị giữa tất cả các instance.

class Counter
  @@count = 0

  def initialize
    @@count += 1
  end

  def self.total
    @@count
  end
end

3.times { Counter.new }
puts Counter.total  # => 3

###########################################################

# 🧩 7️⃣ Biến instance của class (ít dùng hơn @@)
# Dùng @ ngay trong class để lưu dữ liệu không chia sẻ ra ngoài.

class Config
  @app_name = "MyApp"

  def self.app_name
    @app_name
  end
end

puts Config.app_name  # => "MyApp"

###########################################################

# 🧩 8️⃣ Hằng số (Constants)
# Hằng số viết HOA, có thể truy cập bằng ClassName::CONST.

class App
  VERSION = "1.0.0"
end

puts App::VERSION  # => "1.0.0"

###########################################################

# 🧩 9️⃣ Thừa kế (Inheritance)
# Class có thể kế thừa class khác bằng `<`.

class Animal
  def speak
    "Some sound"
  end
end

class Dog < Animal
  def speak
    "Woof!"
  end
end

puts Dog.new.speak  # => "Woof!"

###########################################################

# 🧩 🔟 Gọi super
# Dùng `super` để gọi method cùng tên ở class cha.

class Human
  def greet
    "Xin chào!"
  end
end

class Vietnamese < Human
  def greet
    super + " Tôi là người Việt."
  end
end

puts Vietnamese.new.greet
# => "Xin chào! Tôi là người Việt."

###########################################################

# 🧩 11️⃣ Private và Public methods
# `public` là mặc định. Dùng `private` để ẩn method.

class Account
  def initialize(balance)
    @balance = balance
  end

  def show_balance
    puts "Số dư: #{@balance}" if logged_in?
  end

  private

  def logged_in?
    true
  end
end

Account.new(5000).show_balance  # => "Số dư: 5000"

###########################################################

# 🧩 12️⃣ Object methods sẵn có
# Mọi object Ruby đều có sẵn các method như:
# .class, .object_id, .respond_to?, .is_a?, .instance_variables

obj = "Ruby"
puts obj.class             # => String
puts obj.object_id         # => ID duy nhất của object
puts obj.respond_to?(:upcase) # => true
puts obj.is_a?(String)     # => true

###########################################################

# ✅ Tổng kết nhanh:
# - class ... end: định nghĩa lớp
# - initialize: khởi tạo đối tượng
# - @: instance variable
# - @@: class variable
# - attr_accessor: getter/setter
# - self.method: class method
# - < : kế thừa
# - super: gọi hàm cha
# - private/public: quyền truy cập
###########################################################
