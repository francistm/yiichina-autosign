FROM ruby:2.2.0
MAINTAINER Francis <francis.tm@gmail.com>

RUN git clone https://gist.github.com/87e89b4c7e645cedada5.git /opt/scripts/yiichina-auto-sign

WORKDIR /opt/scripts/yiichina-auto-sign
RUN bundle install
RUN bundle exec ruby ./auto-sign.rb
