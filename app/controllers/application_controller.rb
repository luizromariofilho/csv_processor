# frozen_string_literal: true

class ApplicationController < ActionController::API
  def current_user
    User.take
  end
end
