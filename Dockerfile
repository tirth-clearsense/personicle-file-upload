FROM ruby:2.7.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs && apt-get install -y postgresql-client
RUN mkdir /fileupload
WORKDIR /fileupload
ENV RAILS_ENV=production

COPY Gemfile /fileupload/Gemfile
COPY Gemfile.lock /fileupload/Gemfile.lock

RUN bundle install
COPY . /fileupload
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]

