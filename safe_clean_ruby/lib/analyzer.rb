class Analyzer
  attr_reader :duplicates, :temp_files, :old_files, :large_files

  def initialize(files_data)
    @files_data = files_data
    @duplicates = []
    @temp_files = []
    @old_files = []
    @large_files = []
  end

  def analyze
    puts "Đang phân tích..."
    get_duplicate_files
    get_temp_files
    get_old_files
    get_large_files

    print_summary
  end

  def get_duplicate_files
    # dựa vào hash để lấy file trùng. Nếu 1 hash trùng thì sẽ tính phần tử đầu tiên
    hash_groups = @files_data.group_by { |file| file[:hash] }

    hash_groups.each do |hash, files|
      next if hash.nil?
      next if files.size <= 1

      files[1..-1].each do |f|
        @duplicates << {
          file: f,
          duplicate_of: files.first[:path],
          hash_group: hash
        }
      end
    end
  end

  def get_temp_files
    # Đuôi file tạm thường gặp
    temp_extensions = ['.tmp', '.temp', '.log', '.bak', '.cache', '.old', '.swp', '.DS_Store']

    # Folder tạm
    temp_patterns = ['cache', 'temp', 'tmp', 'backup', 'Trash']

    @files_data.each do |file|
      is_temp = temp_extensions.include?(file[:extension].downcase) || temp_patterns.any? { |pattern| file[:path].downcase.include?(pattern) }

      @temp_files << file if is_temp
    end
  end

  def get_old_files
    # Lấy file nếu quá 180 ngày không truy cập. Dựa vào accessed_at
    old_date = Time.now - (180 * 24 * 60 * 60)
    @files_data.each do |file|
      if file[:accessed_at] < old_date
        @old_files << {
          file: file,
          num_date_no_accessed: ((Time.now - file[:accessed_at])/ 86400).to_i
        }
      end
    end
  end

  def get_large_files
    @large_files = @files_data.sort_by { |file| -file[:size] }.find { |f| f[:size] > 100 * 1024 * 1024 } || []
  end

  def total_size_release
    total = 0

    total += @duplicates.sum { |f| f[:file][:size] }
    total += @temp_files.sum { |f| f[:size] }
    old_total = @old_files.reject { |f| @temp_files.include?(f[:file]) }
    total += old_total.sum { |f| f[:file][:size] }

    total
  end

  private
    def print_summary
      puts "="*50
      puts "Kết quả phân tích".upcase
      puts "Tổng file: #{@files_data.size}"
      puts "Trùng: #{@duplicates.size} | Tạm: #{@temp_files.size} | Cũ: #{@old_files.size} | Lớn trên 100MB: #{@large_files.size}"
      puts "Dung lượng có thể giải phóng: #{total_size_release.to_f.to_unit}"
      puts "="*50
    end
end
