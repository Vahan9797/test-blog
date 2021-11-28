class AuthenticateUser
  prepend SimpleCommand

  def initialize(params)
    p "PARAMS: #{params}"
    @email = params[:email]
    @password = params[:password]
    @user = nil
  end

  def call
    user
    return @user.token if @user.token_expires_at > Time.now

    JsonWebToken.encode(id: @user.id)
  end

  private

  attr_accessor :email, :password

  def user
    p "IN USER: #{email} #{password}"
    @user if (@user = User.find_by(email: email)).authenticate(password)
  rescue
    { error: 'Invalid credentials.' }
  end
end
