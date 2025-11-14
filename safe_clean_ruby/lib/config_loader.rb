class ConfigLoader
  attr_reader :config

  DEFAULT_CONFIG = {
    'default_paths' => ['~/Downloads/SequenceDesignExample', '~/Documents/ruby-oop', '~/Desktop'],
    'exclude_dirs' => ['.git', 'node_modules', '.bundle', 'vendor', 'Library', 'System', 'Applications']
  }.freeze
  # disable runtime mutation warning
  # rubocop:disable Style/MutableConstant
  VALIDATION_RULES = {}
  # rubocop:enable Style/MutableConstant

  def initialize(config_path = nil)
    @config_path = config_path
    @config = set_config
    @validation_errors = []

    validate_config!
  end

  def set_config
    DEFAULT_CONFIG.dup
  end

  def validate_config!
    @validation_errors.clear
    VALIDATION_RULES.each do |key, validator|
      value = @config[key]

      begin
        @validation_errors << "Invalid value for '#{key}': #{value.inspect}" unless validator.call(value)
      rescue ArgumentError => e
        @validation_errors << "Validation error for '#{key}': #{e.message}"
      end
    end

    return unless @validation_errors.any?

    raise ConfigValidationError, @validation_errors.join("\n")
  end

  def default_paths
    paths = @config['default_paths'] || []

    paths.map { |path| File.expand_path(path) }
  end

  class << self
    def add_validation(key, &block)
      VALIDATION_RULES[key] = block
    end
  end
end

# custom error
class ConfigValidationError < StandardError; end
