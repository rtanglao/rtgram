#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'mongo'
require 'set'

Mongo::Logger.logger.level = ::Logger::FATAL # http://stackoverflow.com/questions/30292100/how-can-i-disable-mongodb-log-messages-in-console

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

MIN_DATE = Time.local(2015,1,1, 0, 0)
MAX_DATE = Time.local(2015,1,1, 23, 59)

dir = File.readlines("1pxX150px-jpgs.txt")

for day_number in 1..365 do
  query = {}
  query["datetaken"] = {"$gte" => MIN_DATE, "$lte" => MAX_DATE}
  photosColl.\
    find(query).projection({"datetaken" => 1, "id"=> 1}).\
    sort({"datetaken" => 1}).each do |photo|
    id = photo["id"]
    index = dir.index{|s| s=~ /#{id}/}
    next if index.nil?
    print dir[index]    
  end
  MIN_DATE += 60 * 60 * 24
  MAX_DATE += 60 * 60 * 24
  exit
end
