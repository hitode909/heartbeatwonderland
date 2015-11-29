require 'rubygems'
require 'bundler'

Bundler.require
use Rack::Session::Cookie,
  :key => 'rack.session',
  :expire_after => 2592000,
  :secret => 'hufhxajnkadgwnohgrqoxhoxghbiwqhf'
use Rack::Protection::FormToken

require './heartbeatwonderland'
run HeartBeatWonderLandApp
