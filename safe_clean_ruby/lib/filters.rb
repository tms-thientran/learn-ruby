# Thực hành proc cho việc filters các file phù hợp
module Filters
  def self.size_larger_than(min_size)
    proc { |file| file[:size] > min_size }
  end

  def self.exclude_extension(extensions)
    proc { |file| !extensions.include?(file[:extension]) }
  end
end
