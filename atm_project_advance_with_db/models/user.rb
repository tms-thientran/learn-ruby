require_relative './application_record'

class User
  include ApplicationRecord
  columns :id, :username, :password

  attr_accessor :id, :username, :password

  def account
    @account ||= Account.find_by_user_id(@id) || begin
      acc = Account.new(user_id: @id)
      acc.save
      acc
    end
  end
end
