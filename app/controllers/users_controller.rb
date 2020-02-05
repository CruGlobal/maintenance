# frozen_string_literal: true

class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:no_access]
  def index
    @users = User.order("has_access desc, last_name, first_name")
  end

  def update
    @user = User.find(params[:id])
    @user.update(has_access: params[:has_access])

    redirect_to users_path
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    redirect_to users_path
  end

  def no_access
    redirect_to("/") && return if current_user.has_access?
  end
end
