require 'csv'
require 'fileutils'

class Deleter
  def initialize(file_csv)
    @file_csv = file_csv

    @deleted_files = []
    @failed_files = []
  end

  def delete_file_from_csv
    file_mark_deletes = []
    accept_strings = ['x', 'true', 'yes']
    CSV.foreach(@file_csv, headers: true) do |row|
      mark = row['Mark for Delete']&.downcase
      if accept_strings.include?(mark)
        file_mark_deletes << {
          file_path: row['Path'] || '',
          file_name: row['Filename'] || '',
          file_size: row['Size'].to_f || ''
        }
      end
    end

    if file_mark_deletes.empty?
      puts "⚠️ Không có file nào được đánh dấu để xoá"
      return
    end

    total_size = calc_size_match_unit(file_mark_deletes.sum { |f| f[:file_size].to_f })
    count_files = file_mark_deletes.size

    puts "⚠️ Bạn sắp xóa #{count_files} file, tổng #{total_size}"
    puts "Các file sẽ được chuyển vào ./safe_delete/"
    print "Tiếp tục? (yes/No): "

    case gets.chomp.strip.downcase
    when 'yes', 'y'
      handle_delete_files(file_mark_deletes)
    else
      puts "Mặc định là NO. Cảm ơn bạn"
    end
  end

  def handle_delete_files(file_mark_deletes)
    file_mark_deletes.each do |file|
      safe_delete_file(file)
    end
    save_log
    print_summary
  end

  def safe_delete_file(root_path = 'safe_delete', file)
    FileUtils.mkdir_p(root_path)

    file_path = file[:file_path]
    unless File.exist?(file_path)
      @failed_files << { file_path: file, note: "File không tồn tại" }
      return
    end

    begin
      folder_path = file_path.sub(/^\//, '') #bỏ dấu / đầu tiên

      destinate_path = File.join(root_path, folder_path)
      
      dirname = File.dirname(destinate_path)

      FileUtils.mkdir_p(dirname)

      FileUtils.copy(file_path, destinate_path)

      @deleted_files << {
        original_path: file_path,
        safe_delete_path: destinate_path,
        deleted_at: Time.now,
        size: file[:file_size]
      }
    rescue => e
      @failed_files << { file_path: file, note: e.message }
      puts "Lỗi #{e.message}"
    end
  end

  def save_log(folder_logs = 'logs')
    FileUtils.mkdir_p(folder_logs)

    log_file_name = "log_#{Time.now.strftime('%Y%m%d_%H%M%S')}.csv"

    log_file = File.join(folder_logs, log_file_name)

    CSV.open(log_file, 'wb', encoding: 'UTF-8', write_headers: true, headers: 
      ['Original Path', 'Safe Delete Path', 'Deleted At', 'Size']) do |csv|
        @deleted_files.each do |file|
          csv << [
            file[:original_path],
            file[:safe_delete_path],
            file[:deleted_at].strftime('%Y-%m-%d %H:%M:%S'),
            file[:size],
          ]
        end
    end
  end

  def print_summary
    puts "\n" + "="*50
    puts "✅ KẾT QUẢ XÓA FILE"
    puts "="*50
    puts "✅ Thành công: #{@deleted_files.size} file"
    puts "❌ Thất bại: #{@failed_files.size} file" if @failed_files.any?
    
    total_size = @deleted_files.sum { |f| f[:size] }
    puts "💾 Tổng dung lượng đã giải phóng: #{calc_size_match_unit(total_size)}"
    puts "="*50
    
    # Hiển thị thông báo macOS (nếu có)
    send_notification(total_size) if total_size > 0
  end

  def send_notification(size_b)
    return unless RUBY_PLATFORM.include?('darwin') # Chỉ chạy trên macOS
    
    message = "Hoàn tất dọn dẹp #{calc_size_match_unit(size_b)} - #{@deleted_files.size} files"
    system("terminal-notifier -title SafeClean -message '#{message}'")
    
    # Phát âm thanh (optional)
    system('afplay /System/Library/Sounds/Glass.aiff 2>/dev/null &')
  rescue
    # Bỏ qua nếu lỗi (không quan trọng)
  end

  private

  def calc_size_match_unit(bytes)
    units = ['B', 'KB', 'MB', 'GB', 'TB']
    index = 0

    while bytes > 1024 && index < units.length - 1
      bytes /= 1024
      index += 1
    end

    "#{bytes.round(2)} #{units[index]}"
  end
end
