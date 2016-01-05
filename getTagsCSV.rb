#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'time'
require 'date'
require 'pp'
require 'time'
require 'date'
require 'mongo'


MONGO_HOST = ENV["MONGO_HOST"]
raise(StandardError,"Set Mongo hostname in ENV: 'MONGO_HOST'") if !MONGO_HOST
MONGO_PORT = ENV["MONGO_PORT"]
raise(StandardError,"Set Mongo port in ENV: 'MONGO_PORT'") if !MONGO_PORT
MONGO_USER = ENV["MONGO_USER"]
MONGO_PASSWORD = ENV["MONGO_PASSWORD"]
INSTAGRAM_DB = ENV["INSTAGRAM_DB"]
raise(StandardError,"Set Mongo instagram database name in ENV: 'INSTAGRAM_DB'") if !INSTAGRAM_DB

db = Mongo::Client.new([MONGO_HOST], :database => INSTAGRAM_DB, :port => MONGO_PORT)
if MONGO_USER
  auth = db.authenticate(MONGO_USER, MONGO_PASSWORD)
  if !auth
    raise(StandardError, "Couldn't authenticate, exiting")
    exit
  end
end

photosColl = db[:photos]
tag_counts = {}

photosColl.find().each do |p|
  p["tags"].each do |tag|
    $stderr.printf("TAG:%s\n", tag)
    if tag_counts.has_key?(tag)
      tag_counts[tag] += 1
    else
      tag_counts[tag] =1
    end
  end
end
sorted_tag_counts =
  tag_counts.sort_by{|tag,count| count}.reverse
pp sorted_tag_counts
sorted_tag_counts.each do |tag, count|
  printf("%s,%d\n", tag, count)
end
