FROM 056154071827.dkr.ecr.us-east-1.amazonaws.com/base-image-ruby-version-arg:2.4
MAINTAINER cru.org <wmd@cru.org>

ARG RAILS_ENV=production
ARG SECRET_KEY_BASE

COPY Gemfile Gemfile.lock ./

RUN bundle install --jobs 20 --retry 5 --path vendor
RUN bundle binstub puma rake

COPY . ./

ARG REDIS_PORT_6379_TCP_ADDR=localhost
RUN bundle exec rake assets:clobber assets:precompile RAILS_ENV=production

## Run this last to make sure permissions are all correct
RUN mkdir -p /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads && \
  chmod -R ugo+rw /home/app/webapp/tmp /home/app/webapp/db /home/app/webapp/log /home/app/webapp/public/uploads