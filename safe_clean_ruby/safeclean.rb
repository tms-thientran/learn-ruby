require 'fileutils'
require 'optparse'
require 'pry'

require_relative 'lib/filters'
require_relative 'lib/config_loader'
require_relative 'lib/config_validators'
require_relative 'lib/scanner'
require_relative 'lib/analyzer'
require_relative 'lib/exporter'
require_relative 'lib/deleter'
require_relative 'lib/rollback'

# Load gems (neu chua cai se bao loi)
begin
  require 'pastel'
  require 'tty-prompt'
  require 'tty-progressbar'
rescue LoadError
  puts 'Gem not installed'
  puts 'Please run: bundle install'
  exit 1
end

class SafeClean
  def initialize
    ConfigLoader.add_validation('default_paths') do |paths|
      ConfigValidators.valid_paths.call(paths)
    end

    @config = ConfigLoader.new
    @prompt = TTY::Prompt.new(interrupt: :signal)
    @pastel = Pastel.new
  end

  # Se co cac buoc sau
  # B1: Chon thu muc
  # B2: Quet file co trong thu muc
  # B3: Phan tich
  # B4: Xuat file csv
  # B5: Review
  def start
    show_banner

    selected_paths = select_directory

    return if selected_paths.empty?

    scanner = Scanner.new(@config.config['exclude_dirs'])

    # Ứng dụng proc
    scanner.filter(Filters.size_larger_than(-1))
      .filter(Filters.exclude_extension(['.mp4']))

    files_data = scanner_files(scanner, selected_paths)

    if files_data.empty?
      puts 'Không có file để phân tích'
      return
    end

    analyzer = Analyzer.new(files_data)
    analyzer.analyze

    # Áp dụng kiến thức của metaprograming để in ra theo đuôi files
    # Dùng define_method để tạo ra hàm group theo extension là tính tổng size và tổng file
    # Dùng method_missing để lấy file có size lớn nhất
    # .jpg
    # - Files: 234
    # - Size: 450.5 MB
    # - Lớn nhất: IMG_9876.jpg (15.2 MB)
    puts "\n#{@pastel.cyan('=' * 50)}"
    puts @pastel.cyan('📊 THỐNG KÊ THEO LOẠI FILE')
    puts @pastel.cyan('=' * 50)

    analyzer.count_by_extension.sort_by { |_, count| -count }.first(5).each do |ext, count|
      sizes = analyzer.total_size_by_extension
      larger_file = analyzer.largest_by_extension(ext)
      puts @pastel.yellow("  #{ext.ljust(10)}")
      puts "   - Files: #{count}"
      puts "   - Size: #{sizes[ext].to_f.to_unit}"
      puts "   - Lớn nhất #{larger_file[:filename]} (#{larger_file[:size].to_f.to_unit})"
    end

    exporter = Exporter.new(files_data, analyzer)
    csv_file = handle_export(exporter)

    option_reviews(csv_file)
  end

  def safe_delete
    file_csv = select_file_delete

    deleter = Deleter.new(file_csv)
    deleter.delete_file
  end

  def select_file_delete
    export_files = Dir.glob('exports/safeclean_*').reverse

    if export_files.empty?
      puts 'Không có file để xử lý'
      return
    end

    file_csv = @prompt.select('Vui lòng chọn file cần xử lý xoá', export_files)

    unless File.exist?(file_csv)
      puts 'File không tồn tại'
      return
    end

    file_csv
  end

  def rollback(all_files: false)
    rollback = Rollback.new

    if all_files
      rollback.rollback_all_files
    else
      rollback.rollback_by_file_lastest
    end
  end

  private

  def show_banner
    puts @pastel.bright_yellow('=' * 50)
    puts '🎨 SafeClean - Hệ thống xoá file an toàn'
    puts @pastel.bright_yellow('=' * 50)
  end

  def select_directory
    puts @pastel.cyan('Chọn thư mục muốn quét: ')
    default_paths = @config.default_paths.select { |path| Dir.exist?(path) }

    choices = default_paths.map do |p|
      size = calc_dir_size(p)
      { value: p, name: "#{p}: size (#{size})" }
    end

    choices << { name: 'Nhập đường dẫn khác ...', value: :custom }

    selected = @prompt.multi_select(
      'Có thể chọn nhiều thư mục',
      choices, per_page: 10, help: '(↑↓ di chuyển, Space chọn, Enter xác nhận)'
    )

    if selected.include?(:custom)
      selected.delete(:custom)

      loop do
        custom_path = @prompt.ask('Nhập đường dẫn thư mục: ', require: false) do |q|
          q.validate ->(input) { Dir.exist?(File.expand_path(input)) }
          q.messages[:valid?] = 'Thư mục không tồn tại'
        end
        break if custom_path.nil? || custom_path.empty?

        selected << File.expand_path(custom_path)

        add_more = @prompt.ask('Thêm thư mục khác ?')

        break unless add_more
      end
    end

    if selected.empty?
      puts @pastel.yellow('⚠️ Bạn chưa chọn thư mục nào')
      return []
    end

    puts "\n#{@pastel.green("✅ Đã chọn #{selected.size} thư mục:")}"
    selected.each_with_index do |path, idx|
      puts @pastel.dim("   #{idx + 1}. #{path}")
    end
    puts ''

    selected
  end

  def calc_dir_size(path)
    total = 0
    begin
      count = 0
      Dir.glob(File.join(path, '*')) do |_f|
        total += File.size(path) if File.exist?(path)
        count += 1
        break if count > 100
      end

      total.to_f.to_unit
    rescue StandardError
      'Unknow'
    end
  end

  def scanner_files(scanner, paths)
    return if paths.empty?

    all_files_data = []

    paths.each_with_index do |path, idx|
      puts @pastel.cyan("\n🔍 [#{idx + 1}/#{paths.size}] Đang quét: #{path}")
      puts @pastel.cyan('   Đang đếm file...')

      total_files = Scanner.count_files(path, @config.config['exclude_dirs'])

      if total_files.zero?
        puts @pastel.yellow('   ⚠️ Không có file nào')
        next
      end

      puts @pastel.cyan("   📊 Tìm thấy #{total_files} file")

      # Tạo progress bar cho thư mục này
      bar = TTY::ProgressBar.new(
        '   [:bar] :percent :current/:total | :eta',
        total: total_files,
        width: 45
      )

      # Quét và thêm vào kết quả
      files_data = scanner.scan(path, bar) do |file_info|
        # puts "   Infor của file trong từng path #{file_info[:size]}"
        file_info[:size].positive?
      end
      all_files_data.concat(files_data) if files_data && !files_data.empty?

      puts @pastel.green("✅ Lấy được dữ liệu của #{files_data.size}/#{total_files} files")
    end

    puts @pastel.bright_green("\n🎉 Tổng dữ liệu thu thập được: #{all_files_data.size} file từ #{paths.size} thư mục")

    all_files_data
  end

  def handle_export(exporter)
    choices = [
      { name: 'CSV (nhẹ, dễ xem)', value: :csv },
      { name: 'Bỏ qua', value: :quit }
    ]
    option = @prompt.select('Bạn có muốn xuất kết quả', choices)

    if option.nil?
      puts 'Không khả dụng'
      return
    end

    exporter.export(option)
  end

  def web(csv_file)
    return unless csv_file

    require_relative 'web/app'
    SafeCleanWebApp.start(csv_file)
  end

  def option_reviews(file_csv)
    return unless file_csv

    review = @prompt.select('Bạn muốn review file?') do |menu|
      menu.choice 'Mở Finder', :finder
      menu.choice 'Mở WEB', :web
      menu.choice 'Tôi tự mở', :self_open
    end

    case review
    when :finder
      system("open #{file_csv}") if RUBY_PLATFORM.include?('darwin')
      puts @pastel.green('Đã mở file CSV')
    when :web
      web(file_csv)
    when :self_open
      nil
    end
  end
end

trap('INT') do
  puts "\n\nExiting..."
  exit
end

# ===== MAIN EXECUTION =====

if __FILE__ == $PROGRAM_NAME
  # Parse command line arguments
  command = ARGV.shift
  options = ARGV

  safeclean = SafeClean.new

  case command
  when 'start', nil
    safeclean.start

  when 'delete'
    safeclean.safe_delete
  when 'rollback'
    if options.include?('--all_files')
      safeclean.rollback(all_files: true)
    else
      safeclean.rollback
    end
  else
    puts "❌ Lệnh không hợp lệ: #{command}"
  end
end
