# frozen_string_literal: true

class RegexesController < ApplicationController
  def index
    @regexes = Regex.all
  end

  def create
    regex = Regex.new(params[:pattern], params[:target])
    regex.save

    redirect_to regexes_path
  end

  def destroy
    regex = Regex.new(Base64.decode64(params[:id]))
    regex.destroy

    redirect_to regexes_path
  end
end
