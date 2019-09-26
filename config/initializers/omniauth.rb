# frozen_string_literal: true

silence_warnings do
  OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
end
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cas, url: "https://thekey.me/cas"
end

OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
