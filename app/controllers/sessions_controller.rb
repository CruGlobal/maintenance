# frozen_string_literal: true

class SessionsController < ApplicationController
  skip_before_action :authenticate, only: [:new, :create]

  def new
  end

  def create
    @user = User.find_or_create_from_auth_hash(auth_hash)
    self.current_user = @user
    session[:id_token] = auth_hash.dig("extra", "id_token")
    redirect_to "/"
  end

  def destroy
    session[:user_id] = nil
    redirect_to "#{ENV.fetch("OKTA_ISSUER")}/v1/logout?id_token_hint=#{session[:id_token]}&post_logout_redirect_uri=#{request.base_url}"
  end

  protected

  def auth_hash
    request.env["omniauth.auth"]
  end
end
