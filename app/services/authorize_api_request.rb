class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(headers = {})
    @headers = headers
  end

  def call
    begin
      User.find_by(email: @decoded_auth_token[:email]) if decoded_auth_token
    rescue => e
      raise e
    end
  end

  private

  attr_reader :headers

  def decoded_auth_token
    begin
      @decoded_auth_token ||= JsonWebToken.decode(http_auth_header)
    rescue => e
      raise e
    end
  end

  def http_auth_header
    return headers['Authorization'].split(' ').last if headers['Authorization'].present?
  end
end