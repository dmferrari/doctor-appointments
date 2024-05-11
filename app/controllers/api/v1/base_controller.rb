# frozen_string_literal: true

module Api
  module V1
    class BaseController < ApplicationController
      # before_action :authenticate_user!
      respond_to :json
    end
  end
end
