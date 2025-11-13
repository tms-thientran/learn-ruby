require 'csv'
require 'fileutils'
require_relative '../utils/float'

class Rollback
  def initialize(folder_log = 'logs')
    @folder_log = folder_log
    @failed_files = []
    @restored_files = []
  end

  # rollback theo file mới nhất, rollback toàn bộ folder
  def rollback_by_file_lastest
    # Đọc file logs. Lấy ra thông tin Safe Delete Path
    # In thông tin sắp rollback bao gồm tổng size, tổng file
    # SAu đó mv file từ Safe Delete Path sang thư mục mới có tên là rollbacks
    # In ra summary Kết quả thành công bao nhiêu file, thất bại bao nhiêu file, thời gian
    log_files = Dir.glob(File.join(@folder_log, '*'))

    if log_files.empty?
      puts "Không có file nào để thực hiện rollback"
      return
    end

    last_file = log_files.sort.reverse.first

    puts last_file

    unless File.exist?(last_file)
      puts "File không tồn tại"
      return
    end

    data = get_data_from_file_path(last_file)

    mv_rollback_folder(data)
  end

  def get_data_from_file_path(last_file)
    data_csvs = []
    CSV.foreach(last_file, headers: true) do |row|
      data_csvs << {
        original_path: row['Original Path'] || '',
        deleted_file_path: row['Safe Delete Path'] || '',
        file_size: row['Size'].to_f || 0.to_f
      }
    end

    if data_csvs.empty?
      puts "Không có dữ liệu trong file"
      return
    end
    total_size = data_csvs.sum { |f| f[:file_size]}
    
    puts "="*50
    puts "Dữ liệu sắp rollback".upcase
    puts "Tổng file rollback #{data_csvs.size}"
    puts "Tổng size rollback #{total_size.to_f.to_unit}"
    puts "="*50

    data_csvs
  end

  def mv_rollback_folder(data, folder_rollback = 'rollbacks')
    FileUtils.mkdir_p(folder_rollback)
    puts "Đang xử lý rollback...."
    start_time = Time.now

    data.each do |f|
      handle_rollback_file(f, folder_rollback)
    end

    excute_time = Time.now - start_time

    print_summary(excute_time.round(2))
  end

  def handle_rollback_file(f, folder_rollback)
    deleted_path = f[:deleted_file_path]

    unless File.exist?(deleted_path)
      @failed_files << { file_path: deleted_path, reason: 'File không tồn tại' }
      return false
    end
    destinate_path = File.join(folder_rollback, deleted_path.sub(/^safe_delete\//, ''))

    if File.exist?(destinate_path)
      @failed_files << { file_path: destinate_path, reason: 'File đích đã tồn tại' }
      return false
    end
    
    begin
      FileUtils.mkdir_p(File.dirname(destinate_path))
      FileUtils.mv(deleted_path, destinate_path)

      @restored_files << f

      true
    rescue => e
      @failed_files << { file_path: deleted_path, reason: e.message }
      puts "Lỗi: #{e.message}"
      false
    end
  end

  def print_summary(elapsed_time)
    puts "\n" + "="*50
    puts "✅ KẾT QUẢ PHỤC HỒI"
    puts "="*50
    puts "✅ Thành công: #{@restored_files.size} file"
    puts "❌ Thất bại: #{@failed_files.size} file" if @failed_files.any?
    puts "⏱️  Thời gian: #{elapsed_time}s"
    puts "="*50

    if @failed_files.any?
      puts "\n⚠️ CHI TIẾT FILE THẤT BẠI:"
      @failed_files.each do |f|
        puts "  - #{File.basename(f[:file_path])}: #{f[:reason]}"
      end
    end
  end
end
