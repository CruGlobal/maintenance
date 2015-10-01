class MonitorsController < ApplicationController
  layout nil

  def lb
    render text: 'OK'
  end
end
