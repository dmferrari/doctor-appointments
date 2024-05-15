# frozen_string_literal: true

class ApplicationController < ActionController::API
  respond_to :json

  def current_user
    # TODO: Implement authentication logic
    User.doctors.first
  end
end
