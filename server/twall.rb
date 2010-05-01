#!/usr/bin/env ruby

require 'rubygems'
require 'em-websocket'
require 'uuid'
require 'mq'

uuid = UUID.new

EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080) do |ws|
  ws.onopen do
    puts "client connected"

    twitter = MQ.new
    twitter.queue(uuid.generate).bind(twitter.fanout('twitter')).subscribe do |t|
      ws.send t
    end
  end

  ws.onclose do
    puts "client disconnected"
  end
end

