class RedirectsController < ApplicationController
  def index
    @redirects = Redirect.all
  end

  def update
    @redirect = Redirect.new(Base64.decode64(params[:id]), nil, params['cert'])
    @redirect.save

    render nothing: true
  end

  def create
    redirect = Redirect.new(params[:domain], params['to'], params['cert'])
    redirect.save

    redirect_to redirects_path
  end

  def destroy
    redirect = Redirect.new(Base64.decode64(params[:id]))
            raise redirect.inspect
    redirect.destroy

    redirect_to redirects_path
  end
end
