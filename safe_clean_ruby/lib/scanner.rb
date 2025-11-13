require 'fileutils'
require 'digest'
require 'pry'

class Scanner
  attr_reader :data_files

  def initialize(exclude_dirs)
    @exclude_dirs = exclude_dirs
  end

  def scan(path, bar = nil)
    puts "Đang quét thư mục #{path}"
    data_files = []

    # Khi quét thì sẽ lấy toàn bộ file trog path ở trên, sẽ lấy cả file trong thư mục con nữa. Khi lấy về sẽ trả về dữ liệu tương ứng với file.
    begin
      Dir.glob(File.join(path, "**", "*")).each do |file_path|
        next if File.directory?(file_path)

        next if @exclude_dirs.any? { |dir| file_path.include?(dir) }

        file_info = collect_file_info(file_path)

        data_files << file_info if file_info

        bar&.advance(1)
      end
    rescue => e
      puts "⚠️ Lỗi khi quét: #{e.message}"
    end

    data_files
  end

  def collect_file_info(file_path)
    stat = File.stat(file_path)

    {
      path: file_path,                           # Đường dẫn đầy đủ
      filename: File.basename(file_path),        # Tên file
      extension: File.extname(file_path),        # Đuôi file (.txt, .jpg...)
      size: stat.size,                           # Kích thước (bytes)
      created_at: stat.ctime,                    # Thời gian tạo
      modified_at: stat.mtime,                   # Thời gian chỉnh sửa
      accessed_at: stat.atime,                   # Thời gian truy cập
      hash: calculate_hash(file_path),           # Hash để tìm file trùng
      readable: File.readable?(file_path),       # Có đọc được không
      writable: File.writable?(file_path)        # Có ghi được không
    }
  rescue => e
    puts "Không thể đọc file #{file_path} - #{e.message}"
    nil
  end

  # Tính hash SHA256 của file để tìm file trùng lặp
  # Hash giống nhau = nội dung file giống nhau
  def calculate_hash(file_path)
    # Chỉ hash file nhỏ hơn 100MB để tránh chậm
    return nil if File.size(file_path) > 100 * 1024 * 1024
    
    Digest::SHA256.file(file_path).hexdigest
  rescue
    nil # Nếu lỗi thì trả về nil
  end

  def self.count_files(path, exclude_dirs = [])
    count = 0

    Dir.glob(File.join(path, "**", "*")).each do |file_path|
      next if File.directory?(file_path)

      next if exclude_dirs.any? { |dir| file_path.include?(dir) }

      count +=1
    end

    count
  rescue
    0
  end
end
