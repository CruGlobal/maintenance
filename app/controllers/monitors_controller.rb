class MonitorsController < ApplicationController
  skip_before_action :ensure_login
  skip_before_action :ensure_setup_finished
  layout nil
  newrelic_ignore

  def lb
    render text: 'OK'
  end
end
