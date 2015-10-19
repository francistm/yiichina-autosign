FROM ruby:2.2.0
MAINTAINER Francis <francis.tm@gmail.com>

ADD inc/crontab /etc/
ADD inc/cron-start /usr/bin
ADD inc/sources.list /etc/apt/

RUN apt-get update -qq && apt-get install -y git rsyslog

RUN mkdir -p /opt/cronjobs
RUN touch /var/log/cron.log
RUN chmod +x /usr/bin/cron-start
RUN git clone https://gist.github.com/87e89b4c7e645cedada5.git /opt/cronjobs/yiichina-auto-sign

WORKDIR /opt/cronjobs/yiichina-auto-sign
RUN bundle install

CMD /usr/bin/cron-start