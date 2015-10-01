class AppsController < ApplicationController
  before_action :initialize_index

  def index
    @apps = @index.apps.map{ |app| App.new(app) }
  end

  def update
    @app = App.new(params[:id])

    @app.maintenance = params["maintenance"] if params["maintenance"]
    @app.dependencies = params["dependencies"] if params["dependencies"]

    render nothing: true
  end

  def create
    @index.add_app(params[:name]) unless @index.apps.include?(params[:name])

    redirect_to apps_path
  end

  def destroy
    @index.remove_app(params[:id])

    redirect_to apps_path
  end

  private

  def initialize_index
    @index = Index.new
  end
end
