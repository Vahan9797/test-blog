class Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    begin
      auth_params = user_params
      command = AuthenticateUser.call(auth_params[:email], auth_params[:password])
      
      if command.success?
        user = User.find_by(email: auth_params[:email])
        user.update!(token: command.result) if command.result != user.token
        render json: { email: user.email, auth_token: user.token, user_id: user.id }
      else
        render json: { error: command.errors }, status: :unauthorized
      end
    rescue => e
      if e.is_a? ActiveRecord::RecordInvalid
        render json: { error: 'You must give valid email and password with minimum length of 6 characters' }, status: :forbidden
      else
        render json: { error: "Something went wrong. See: #{e}" }, status: :internal_server_error
      end
    end
  end

  private
  def user_params
    transformed_params = {}

    params.permit(:email, :password).to_unsafe_h.map do |key, value|
      transformed_params[key] = key == 'email' ? value.downcase : value
    end

    transformed_params.symbolize_keys!
  end
end
