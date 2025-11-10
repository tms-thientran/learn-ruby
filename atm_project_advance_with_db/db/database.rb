require "sqlite3"

module Database
    DB_FILE = 'atm.db'

    def self.connection
        @db ||= begin
            db = SQLite3::Database.new(DB_FILE)
            db.results_as_hash = true
            db.execute("PRAGMA foreign_keys = ON")

            db
        end
    end

    def self.execute(sql, params = [])
        connection.execute(sql, params)
    end

    def self.get_first_row(sql, params = [])
        connection.get_first_row(sql, params)
    end

    def self.create_tables
        execute <<-SQL
            CREATE TABLE IF NOT EXISTS users (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                username TEXT UNIQUE,
                password TEXT
            );
        SQL

        execute <<-SQL
            CREATE TABLE IF NOT EXISTS accounts (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id INTEGER,
                balance REAL DEFAULT 0,
                FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE
            );
        SQL
        execute <<-SQL
            CREATE TABLE IF NOT EXISTS transactions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                account_id INTEGER,
                type TEXT,
                amount REAL,
                note TEXT,
                created_at TEXT,
                FOREIGN KEY(account_id) REFERENCES accounts(id) ON DELETE CASCADE
            );
        SQL
    end
end
