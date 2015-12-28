class UsersController < ApplicationController
  skip_before_action :authenticate, only: [:no_access]
  def index
    @users = User.all
  end

  def update
    @user = User.find(params[:id])
    @user.update(has_access: params[:has_access])

    render nothing: true
  end

  def destroy
    user = User.find(params[:id])
    user.destroy

    redirect_to users_path
  end

  def no_access

  end
end
