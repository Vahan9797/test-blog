class AuthenticateUser
  prepend SimpleCommand

  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    JsonWebToken.encode(email: user.email) if user
  end

  private

  attr_accessor :email, :password

  def user
    begin
      user = User.find_by(email: email)
      return user if user && user.authenticate(password)
      nil
    rescue
      { error: 'Invalid credentials.' }
    end
end
end