# frozen_string_literal: true

class ApplicationController < ActionController::Base
  force_ssl(if: :ssl_configured?, except: :lb)

  before_action :authenticate

  def current_user=(user)
    session[:user_id] = user.id
    Thread.current[:user_id] = session[:user_id]
    @current_user = user
  end

  def current_user
    return unless session[:user_id]

    Thread.current[:user_id] = session[:user_id]
    @current_user ||= User.find(session[:user_id])
  end

  def ssl_configured?
    !Rails.env.development? && !Rails.env.test?
  end

  helper_method :current_user

  private

  def authenticate
    redirect_to("/sessions/new") && return unless current_user

    redirect_to "/users/no_access" unless current_user.has_access?
  end
end
