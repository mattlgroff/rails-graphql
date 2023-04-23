FROM ruby:3.2.2-alpine
WORKDIR /app
COPY . .
RUN apk add --no-cache build-base tzdata nodejs postgresql-dev
RUN gem install bundler
RUN bundle install
ENV RAILS_ENV=production
RUN bundle exec rails assets:precompile
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]