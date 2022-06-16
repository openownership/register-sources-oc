FROM ruby:2.7.6-bullseye

WORKDIR /app

COPY Gemfile Gemfile.lock register_sources_oc.gemspec /app/
COPY lib/register_sources_oc/version.rb /app/lib/register_sources_oc/

RUN bundle install

COPY . /app/

CMD ["bundle", "exec", "rspec"]
