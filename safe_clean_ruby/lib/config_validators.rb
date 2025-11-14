# Thực hành kiến thức về lamda. Ứng dụng cho việc gọi validate config
module ConfigValidators
  def self.valid_paths
    ->(paths) {
      return false unless paths.is_a?(Array)

      paths.all? { |path| path.is_a?(String) && !path.empty? }
    }
  end
end
