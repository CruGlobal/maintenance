class ApplicationController < ActionController::Base
  before_action :authenticate

  def current_user=(user)
    session[:user_id] = user.id
    @current_user = user
  end

  def current_user
    return unless session[:user_id]

    @current_user ||= User.find(session[:user_id])
  end
  helper_method :current_user

  private

  def authenticate
    unless current_user
      redirect_to '/auth/cas' and return
    end

    unless current_user.has_access?
      redirect_to '/users/no_access'
    end
  end
end