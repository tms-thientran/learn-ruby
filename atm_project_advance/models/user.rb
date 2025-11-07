require_relative './account.rb'

class User
  attr_accessor :username, :password, :account

  def initialize(username, password)
    @username = username
    @password = password
    @account = Account.new
  end
end
