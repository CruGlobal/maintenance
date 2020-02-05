# frozen_string_literal: true

class CertsController < ApplicationController
  def index
    @certs = Cert.all
  end

  def update
    @cert = Cert.new(Base64.decode64(params[:id]), params["cert"], params["key"])
    @cert.save

    redirect_to certs_path
  end

  def create
    if params[:name] != ''
      cert = Cert.new(params[:name], params["cert"], params["key"])
      cert.save
    end

    redirect_to certs_path
  end

  def destroy
    cert = Cert.new(Base64.decode64(params[:id]))
    cert.destroy

    redirect_to certs_path
  end
end
