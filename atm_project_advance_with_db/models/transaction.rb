require_relative './application_record'

class Transaction
    include ApplicationRecord
    columns :account_id, :type, :amount, :note, :created_at

    def initialize(account)
      @account = account
    end

    def record(type, amount, note = nil)
        tx = Database.execute("INSERT INTO transactions (account_id, type, amount, note, created_at) VALUES (?, ?, ?, ?, ?)",
            [@account.id, type, amount, note, Time.now.strftime("%Y-%m-%d %H:%M:%S")])

        yield if block_given?

        tx
    end

    def show_history
        rows = Database.execute("SELECT * FROM transactions WHERE account_id = ?", [@account.id])
        rows.map do |row|
            {
                type: row["type"],
                amount: row["amount"],
                note: row["note"],
                created_at: row["created_at"]
            }
        end
    end
end
