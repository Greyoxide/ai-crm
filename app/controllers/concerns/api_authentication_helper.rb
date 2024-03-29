module ApiAuthenticationHelper
  extend ActiveSupport::Concern

  included do
    skip_before_action :verify_authenticity_token
    before_action :authenticate_with_bearer_token
  end

  private

  def authenticate_with_bearer_token
    bearer_token = extract_bearer_token(request.headers['Authorization'])

    if bearer_token
      @access_token = ApiKey.find_by(bearer_token: bearer_token)
      puts @access_token.inspect
      unless @access_token and @access_token.active?
        render json: { error: 'Unauthorized' }, status: :unauthorized
      end
    else
      render json: { error: 'Missing or improperly formatted token' }, status: :bad_request
    end
  end

  def extract_bearer_token(authorization_header)
    if authorization_header.present? && authorization_header.start_with?('Bearer ')
      authorization_header.split(' ').last
    else
      nil
    end
  end
end
