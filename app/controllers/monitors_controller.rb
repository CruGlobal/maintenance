# frozen_string_literal: true

class MonitorsController < ApplicationController
  skip_before_action :authenticate, only: [:lb]
  layout nil

  def lb
    render body: 'OK'
  end
end
