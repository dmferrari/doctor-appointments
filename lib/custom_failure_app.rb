# frozen_string_literal: true

class CustomFailureApp < Devise::FailureApp
  def respond
    if request.format.json?
      json_api_error_response
    else
      super
    end
  end

  def json_api_error_response
    self.status = :unauthorized
    self.content_type = 'application/json'
    self.response_body = { error: 'You need to sign in or sign up before continuing.' }.to_json
  end
end
