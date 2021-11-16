class Api::RegistrationController < ApplicationController
  skip_before_action :authenticate_request
  
  def create_user
    begin
      create_params = user_params

      user = User.create!(create_params)

      token = JsonWebToken.encode(email: user.email) if user
      user.update!(token: token)

      render json: { email: user.email, token: user.token, user_id: user.id }
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

    params.permit(:email, :password, :password_confirmation).to_unsafe_h.map do |key, value|
      transformed_params[key] = key == 'email' ? value.downcase : value
    end
    transformed_params
  end
end
