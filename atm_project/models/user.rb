class User
    # Có username, password, tổng số tiền amount, lịch sử transaction
    attr_accessor :username, :password, :balance, :history

    def initialize(username, password)
      @username = username
      @password = password
      @balance = 0
      @history = []
    end
end
