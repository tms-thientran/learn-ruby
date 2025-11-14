require 'fileutils'
require 'csv'

class Exporter
  def initialize(files_data, analyzer)
    @files_data = files_data
    @analyzer = analyzer
  end

  def export(option, folder_path = 'exports')
    # Tạo folder chứa file nếu chưa có
    # tạo tên file
    # open file và ghi dữ liệu vào file
    # Dữ liệu có header, body
    case option
    when :csv
      puts 'Đang xử lý export...'
      full_forder_path = File.join(Dir.pwd, folder_path)
      FileUtils.mkdir(full_forder_path) unless File.directory?(full_forder_path)

      name_file = "safeclean_#{Time.now.to_i}.csv"
      file_path = File.join(full_forder_path, name_file)

      CSV.open(file_path, 'wb',
               encoding: 'UTF-8',
               write_headers: true,
               headers: header_options) do |csv|
        @files_data.each do |file|
          csv << build_csv_row(file)
        end
      end

      puts '✅ Xuất csv thành công'
      file_path
    when :quit
      puts 'Đã bỏ qua export!!!'
    else
      puts 'unknown'
    end
  end

  def header_options
    [
      'Path', # Đường dẫn file
      'Filename', # Tên file
      'Size', # Kích thước
      'Extension', # Đuôi file
      'Last Modified', # Ngày sửa cuối
      'Last Accessed', # Ngày truy cập cuối
      'Warning Type', # Loại cảnh báo
      'Duplicate Group', # Nhóm trùng (nếu có)
      'Mark for Delete', # Đánh dấu xóa (người dùng sẽ điền)
      'Note' # Ghi chú
    ]
  end

  def build_csv_row(file)
    [
      file[:path],
      file[:filename],
      file[:size],
      file[:extension],
      file[:modified_at].strftime('%Y-%m-%d'),
      file[:accessed_at].strftime('%Y-%m-%d'),
      waring_type(file),
      group_duplicate(file),
      '',
      ''
    ]
  end

  def waring_type(file)
    # Có OLD, LARGE, TEMP, DUPLICATE
    warning_types = []

    warning_types << 'OLD' if old?(file)
    warning_types << 'LARGE' if large?(file)
    warning_types << 'TEMP' if temp?(file)
    warning_types << 'DUPLICATE' if duplicate?(file)

    warning_types.empty? ? 'OK' : warning_types.join(',')
  end

  def group_duplicate(file)
    dup = @analyzer.duplicates.find { |f| f[:path] == file[:path] }

    dup ? dup[:hash_group][0..8] : ''
  end

  def old?(file)
    @analyzer.old_files.any? { |f| f[:file][:path] == file[:path] }
  end

  def large?(file)
    @analyzer.large_files.any? { |f| f[:path] == file[:path] }
  end

  def temp?(file)
    @analyzer.temp_files.any? { |f| f[:path] == file[:path] }
  end

  def duplicate?(file)
    @analyzer.duplicates.any? { |f| f[:file][:path] == file[:path] }
  end
end
