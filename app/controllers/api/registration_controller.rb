class Api::RegistrationController < ApplicationController
  skip_before_action :authenticate_request
  
  def create_user
    begin
      user = User.create!(user_params)
      user.update!(token: JsonWebToken.encode(id: user.id))

      render json: { email: user.email, token: user.token, user_id: user.id }
    rescue => e
      render json: { error: "Something went wrong. See: #{e}" }
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation).tap do |user_params|
      user_params.require([:email, :password, :password_confirmation])
    end
  end
end
