# frozen_string_literal: true

class UpstreamsController < ApplicationController
  def index
    @upstreams = Upstream.all
  end

  def update
    upstream = Redirect.new(Base64.decode64(params[:id]), params["target"])
    upstream.save

    head :ok
  end

  def create
    upstream = Upstream.new(params[:path], params[:target])
    upstream.save

    redirect_to upstreams_path
  end

  def destroy
    upstream = Upstream.new(Base64.decode64(params[:id]))
    upstream.destroy

    redirect_to upstreams_path
  end
end
