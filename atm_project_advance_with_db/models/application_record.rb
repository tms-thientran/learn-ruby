require_relative "../db/database.rb"

module ApplicationRecord
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def method_missing(name, *args)
      if name.to_s =~ /^find_by_(.+)$/
        column = $1
        row = Database.get_first_row("SELECT * FROM #{table_name} WHERE #{column} = ?", [args.first])
        row ? new_from_row(row) : nil
      else
        super
      end
    end

    def respond_to_missing?(method_name, include_private = false)
      method_name.to_s.start_with?("find_by_") || super
    end

    def table_name
      "#{self.name.downcase}s"
    end

    def new_from_row(row)
      obj = self.new
      row.each { |k,v| obj.instance_variable_set("@#{k}", v) if obj.instance_variables.include?("@#{k}".to_sym) || obj.respond_to?("#{k}=") }
      obj
    end

    def columns(*names)
      @columns = names if names.any?
      @columns
    end

    def all
      Database.execute("SELECT * FROM #{table_name}").map { |row| new_from_row(row) }
    end
  end

  # Instance methods
    def save
        columns = self.class.columns.reject { |c| c == :id } # loại id khỏi danh sách columns
        values = columns.map { |col| instance_variable_get("@#{col}") }
        db = Database.connection

        if @id.nil?
            # INSERT mới
            placeholders = (["?"] * columns.size).join(", ")
            sql = "INSERT INTO #{self.class.table_name} (#{columns.join(", ")}) VALUES (#{placeholders})"
            db.execute(sql, values)
            @id = db.last_insert_row_id
        else
            # UPDATE nếu đã có id
            set_clause = columns.map { |col| "#{col} = ?" }.join(", ")
            sql = "UPDATE #{self.class.table_name} SET #{set_clause} WHERE id = ?"
            db.execute(sql, values + [@id])
        end
    end
end
