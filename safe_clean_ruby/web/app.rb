require 'sinatra'
require 'csv'
require 'json'

class SafeCleanWebApp < Sinatra::Base
  # Biến lưu đường dẫn file CSV hiện tại
  set :csv_file, nil

  get '/' do
    csv_file = settings.csv_file

    @files = []
    CSV.foreach(csv_file, headers: true, encoding: 'UTF-8') do |row|
      @files << {
        path: row['Path'],
        filename: row['Filename'],
        size: row['Size'],
        extension: row['Extension'],
        modified: row['Last Modified'],
        warning: row['Warning Type'],
        duplicate_group: row['Duplicate Group'],
        marked: %w[true x].include?(row['Mark for Delete']&.downcase),
        note: row['Note']
      }
    end

    # Tính tóm tắt
    @total_files = @files.size
    @marked_count = @files.count { |f| f[:marked] }
    @total_size = @files.sum { |f| f[:size].to_f }
    @marked_size = @files.select { |f| f[:marked] }.sum { |f| f[:size].to_f }

    erb :index
  end

  post '/save' do
    content_type :json

    csv_file = settings.csv_file
    return { success: false, message: 'File CSV không tồn tại' }.to_json unless csv_file && File.exist?(csv_file)

    # Nhận dữ liệu từ client
    data = JSON.parse(request.body.read)
    marked_paths = data['marked_paths'] || []
    notes = data['notes'] || {}

    # Đọc CSV hiện tại
    rows = []
    CSV.foreach(csv_file, headers: true, encoding: 'UTF-8') do |row|
      path = row['Path']

      # Cập nhật mark và note
      row['Mark for Delete'] = marked_paths.include?(path) ? 'TRUE' : ''
      row['Note'] = notes[path] || row['Note']

      rows << row
    end

    # Ghi lại file CSV
    CSV.open(csv_file, 'wb', encoding: 'UTF-8', write_headers: true, headers: rows.first.headers) do |csv|
      rows.each { |row| csv << row }
    end

    { success: true, message: 'Đã lưu thành công' }.to_json
  end

  # API: Preview nội dung file text
  get '/preview/:index' do
    csv_file = settings.csv_file
    index = params[:index].to_i

    # Đọc file tại index
    files = []
    CSV.foreach(csv_file, headers: true, encoding: 'UTF-8') do |row|
      files << row
    end

    return { error: 'Index không hợp lệ' }.to_json if index.negative? || index >= files.size

    file_path = files[index]['Path']

    # Chỉ preview file text và nhỏ hơn 50KB
    return { error: 'File quá lớn để preview (>50KB)' }.to_json if File.size(file_path) > 50 * 1024

    text_extensions = ['.txt', '.log', '.md', '.csv', '.json', '.yml', '.yaml']
    ext = File.extname(file_path).downcase

    return { error: 'File không phải định dạng text' }.to_json unless text_extensions.include?(ext)

    begin
      content = File.read(file_path, encoding: 'UTF-8')
      { content: content }.to_json
    rescue StandardError => e
      { error: "Không thể đọc file: #{e.message}" }.to_json
    end
  end

  def self.start(csv_file_path)
    set :csv_file, csv_file_path
    puts "\n🌐 Web preview đang chạy tại: http://localhost:4567"
    puts "Ấn Ctrl+C để dừng\n\n"
    run!
  end
end
