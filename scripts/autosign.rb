require 'logger'
require 'eventmachine'

require File.expand_path('registration.rb', File.dirname(__FILE__))

logger = Logger.new(STDOUT)
user_identity = {}.tap do |identity|
  identity[:username] = ENV['USERNAME'].presence || ARGV[0]
  identity[:password] = ENV['PASSWORD'].presence || ARGV[1]
end

EventMachine.run do
  logger.info "Sign cron started, Press Ctrl+C to stop"

  EventMachine.add_timer(86400) do
    site = YiiChina.new user_identity
    site.registration if site.login
  end

  Signal.trap('INT') { EventMachine.stop }
  Signal.trap('TERM') { EventMachine.stop }
end
