# ============================= Ruby sẽ có các biến như ========================
# 1. Biến toàn cục ở đâu cũng dùng được. VD: $global_var
# 2. Biến instance của object, mỗi instance sẽ là 1 biến riêng biệt. Cách dùng @instance_var
# 3. Biến class. Cách dùng @@class_var. Hiểu như biến static bên php.
# 4. Biến local. Cách dùng như những ngôn ngữ khác VD: count, age
# 5. Const hằng số. Cách dùng VAR1, VAR2
# 6. Một số biến mặc định của ruby: true, false, __LINE__, __FILE__, nil, self

# Luyện tập sử dụng biến
$global_var = 10
class Person
    @@count = 0

    def initialize(name, age)
      @name = name
      @age = age
    end

    def print_global_var
        puts "Test global variables person #$global_var"
    end

    def increament
        @@count += 1
    end

    def self.get_count
        @@count
    end

    def get_info
        puts "My name is #@name. I'm #@age years old"
    end
end

class Animal
    def print_global_var
        puts "Test global variables animal #$global_var"
    end
end

t = Person.new("Thien", 28)
n = Person.new("Ngoc", 28)
# t.get_info
# n.get_info
# t.print_global_var
# puts t.increament
# puts n.increament

dog = Animal.new
# dog.print_global_var

# puts __LINE__
# puts 'escape using "\\"';
# puts "That's right";

# ============================= Một số kiểu dữ liệu ========================
# 1. Interger Numbers
# 2. Float Numbers
# 3. String
# 4. Array
# 5. Hashes
# 6. Ruby Ranges
# 7. Symbol
# 8. Boolean
# 9. Nil
# 10. Regex
# 11. Time

# arrs = ["new", 10, 3.14, "name", nil]

# arrs.each do |arr|
#     puts arr
# end

# colors = { "name" => "Thien", "color" => "green" }

# colors.each do |key, value|
#     puts value
# end

# (1..15).each do |n|
#     puts n
# end
time = Time.now
# puts time.class
# puts time.strftime("%Y-%m-%d")

# BT 1
name = "Thien"
age = 28
tall = 1.72
puts "My name is #{name}, #{age} years old, tall is #{tall}m."

# BT 2
number_int = 10

def bmi(weigh_kg, height_m)
    weigh_kg / (height_m ** 2)
end

puts 1.755.round(2)

# BT 3

text = "  ruby123 rocks "
puts text.upcase.strip.gsub(/\d/, '#')

# BT 4
def change_arr(arr)
    arr.sort.select { |n| n.even?}.map {|n| n*n}
end

puts change_arr([1,2,3,4,6])

# BT 5

def count_words(text)
    words = text.strip.downcase.split
    counts = Hash.new(0)

    words.each do |w|
        counts[w] += 1
    end

    return counts
end

def count_words_by_fetch(text)
    words = text.strip.downcase.split
    counts = {}

    words.each do |w|
        counts[w] = counts.fetch(w, 0) + 1
    end

    return counts
end

def count_words_by_merge(text)
    words = text.strip.downcase.split
    counts = {}

    words.each do |w|
        counts = counts.merge({ w => 1 }) { |_key, old, _new| old + _new }
    end

    return counts
end

puts count_words_by_merge("Ruby ruby js")

