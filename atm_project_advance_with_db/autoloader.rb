module Autoloader
    def self.load!(base_path)
        Dir[File.join(base_path, '**/*.rb')].each do |file|
            class_name = File.basename(file, '.rb').split('_').map(&:capitalize).join

            Object.autoload class_name.to_sym, File.expand_path(file)
        end
    end
end
