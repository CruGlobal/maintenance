class VanitiesController < ApplicationController
  def index
    @vanities = Vanity.all
  end

  def create
    vanity = Vanity.new(params[:path], params[:target])
    vanity.save

    redirect_to vanities_path
  end

  def destroy
    vanity = Vanity.new(Base64.decode64(params[:id]))
    vanity.destroy

    redirect_to vanities_path
  end
end
