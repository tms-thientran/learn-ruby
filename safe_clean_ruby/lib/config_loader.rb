class ConfigLoader
  attr_reader :config
  DEFAULT_CONFIG = {
    'default_paths' => ["~/Downloads/SequenceDesignExample", "~/Documents", "~/Desktop"]
  }.freeze

  def initialize(config_path = nil)
    @config_path = config_path
    @config = set_config
  end

  def set_config
    DEFAULT_CONFIG.dup
  end

  def default_paths
    paths = @config['default_paths'] || []

    paths.map { |path| File.expand_path(path) }
  end
end
