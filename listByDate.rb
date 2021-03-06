#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'curb'
require 'pp'
require 'time'
require 'date'
require 'mongo'
require 'parseconfig'
require 'uri'

if ARGV.length < 6
  puts "usage: #{$0} yyyy mm dd yyyy mmm dd -v"
  exit
end

MIN_DATE = Time.local(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i, 0, 0) # may want Time.utc if you don't want local time
MAX_DATE = Time.local(ARGV[3].to_i, ARGV[4].to_i, ARGV[5].to_i, 23, 59) # may want Time.utc if you don't want local time


MONGO_HOST = ENV["MONGO_HOST"]
raise(StandardError,"Set Mongo hostname in ENV: 'MONGO_HOST'") if !MONGO_HOST
MONGO_PORT = ENV["MONGO_PORT"]
raise(StandardError,"Set Mongo port in ENV: 'MONGO_PORT'") if !MONGO_PORT
MONGO_USER = ENV["MONGO_USER"]
# raise(StandardError,"Set Mongo user in ENV: 'MONGO_USER'") if !MONGO_USER
MONGO_PASSWORD = ENV["MONGO_PASSWORD"]
# raise(StandardError,"Set Mongo user in ENV: 'MONGO_PASSWORD'") if !MONGO_PASSWORD
INSTAGRAM_DB = ENV["INSTAGRAM_DB"]
raise(StandardError,"Set Mongo Instagram database name in ENV: 'INSTAGRAM_DB'") if !INSTAGRAM_DB
FLICKR_USER = ENV["FLICKR_USER"]


db = Mongo::Connection.new(MONGO_HOST, MONGO_PORT.to_i).db(INSTAGRAM_DB)
if MONGO_USER
  auth = db.authenticate(MONGO_USER, MONGO_PASSWORD)
  if !auth
    raise(StandardError, "Couldn't authenticate, exiting")
    exit
  end
end

photosColl = db.collection("photos")

query = {}
query["datetaken"] = {"$gte" => MIN_DATE, "$lte" => MAX_DATE}
photosColl.find(query,
                :fields => ["datetaken", "id", "location"]
                ).sort([["datetaken", Mongo::ASCENDING]]).each do |p|
  location = p["location"]
  printf("photo:%d, datetaken:%s lat:%s, lon:%s\n", p["id"], 
         p["datetaken"].to_s,
         location["latitude"].to_s, location["longitude"].to_s)
end



