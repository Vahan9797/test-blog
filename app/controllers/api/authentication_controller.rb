class Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    auth_params = user_params
    p "#{auth_params} #{auth_params[:email]} #{auth_params[:password]}"
    command = AuthenticateUser.call(auth_params)

    if command.success?
      user = User.find_by!(email: auth_params[:email])

      user.update!(token: command.result, token_expires_at: 24.hours.from_now) if command.result != user.token

      render json: { email: user.email, auth_token: user.token, user_id: user.id }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  rescue => e
    render json: { error: "Something went wrong. See: #{e}" }
  end

  private

  def user_params
    params.require(:authentication).permit(:email, :password).tap do |user_params|
      user_params.require(%i[email password])
    end
  end
end
