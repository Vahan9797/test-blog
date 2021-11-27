class AuthenticateUser
  prepend SimpleCommand

  def initialize(params)
    @email = params[:email]
    @password = params[:password]
    @user = nil
  end

  def call
    if !(@user = user).nil?
      return @user.token if @user.token_expires_at > Time.now
      JsonWebToken.encode(id: @user.id)
    end
  end

  private

  attr_accessor :email, :password

  def user
    begin
      user if (user = User.find_by(email: email)).authenticate(password)
    rescue
      { error: 'Invalid credentials.' }
    end
  end
end