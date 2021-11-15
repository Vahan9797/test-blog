class Api::AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    begin
      command = AuthenticateUser.call(params[:email], params[:password])
  
      if command.success?
        user = User.find_by(email: params[:email])
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
end
