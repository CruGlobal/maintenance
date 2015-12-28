class MonitorsController < ApplicationController
  skip_before_action :authenticate, only: [:lb]
  layout nil

  def lb
    render text: 'OK'
  end
end
