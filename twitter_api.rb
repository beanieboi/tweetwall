#!/usr/bin/env ruby

require 'rubygems'
require 'tweetstream'
require 'mq'
require 'yaml'

config = YAML.load_file("twitter.yml")
USERNAME = config["twitter"]["username"]
PASSWORD = config["twitter"]["password"]
KEYWORDS = ['ichtest']

class TwitterApi
  attr_accessor :username, :password
  
  def initialize(username, password)
    @username = username
    @password = password
  end
  
  def go!
    AMQP.start(:host => 'localhost') do

      twitter_queue = MQ.new.fanout('twitter')

      TweetStream::Client.new(USERNAME,PASSWORD).track(KEYWORDS.join(",")) do |status|
        images = TwitPic.analyze(status.text)
        status.merge!(:images => images) unless images.empty?
        twitter_queue.publish(status.to_json)
      end
    end
  end
end

class TwitPic
  def self.analyze(text)
    scan_for_twitpic = text.scan(/(http:\/\/twitpic.com\/)(\w*)/)
    images = []
    
    unless scan_for_twitpic.empty?
      scan_for_twitpic.each do |twitpic|
        images << "http://twitpic.com/show/full/" + twitpic.last
      end
    end
    
    images
  end
end

api = TwitterApi.new(USERNAME,PASSWORD)
api.go!