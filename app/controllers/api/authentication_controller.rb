class Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    begin
      auth_params = user_params
      command = AuthenticateUser.call(auth_params[:email], auth_params[:password])
      
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
  end

  private
  def user_params
    params.require(:user).permit(:email, :password).tap do |user_params|
      user_params.require([:email, :password])
    end
  end
end
