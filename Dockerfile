FROM ruby:2.2.0
MAINTAINER Francis <francis.tm@gmail.com>

RUN apt-get update -qq && apt-get install -y git

RUN mkdir -p /opt/cronjobs
RUN git clone https://gist.github.com/87e89b4c7e645cedada5.git /opt/cronjobs/yiichina-auto-sign

WORKDIR /opt/cronjobs/yiichina-auto-sign
RUN bundle install

CMD /usr/sbin/cron -f
