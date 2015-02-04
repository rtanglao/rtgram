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
require 'holidays'

if ARGV.length < 6
  puts "usage: #{$0} yyyy mm dd yyyy mmm dd -v"
  exit
end

MIN_DATE = Time.local(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i, 0, 0) # may want Time.utc if you don't want local time
MAX_DATE = Time.local(ARGV[3].to_i, ARGV[4].to_i, ARGV[5].to_i, 23, 59) # may want Time.utc if you don't want local time

begin_2014 = Date.civil(2014,1,1)
end_2014 = Date.civil(2014,12,31)
holiday_start_time = []
Holidays.between(begin_2014, end_2014, :ca_bc).each do |h|
  holiday_time = Time.local(2014,
                            h[:date].month, 
                            h[:date].day, 0, 0).to_i
  $stderr.printf("HOLIDAY_TIME:%d\n", holiday_time)
  holiday_start_time.push(holiday_time)
end

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
printf("instagram_vancouver_holiday_%d_%d_%d_%d_%d_%d = [\n", 
       ARGV[0], ARGV[1], ARGV[2], ARGV[3], ARGV[4], ARGV[5])
photosColl.find(query,
                :fields => ["datetaken", "id", "location"]
                ).sort([["datetaken", Mongo::ASCENDING]]).each do |p|
  location = p["location"]
  datetaken_local = p["datetaken"].getlocal
  date_taken_int = datetaken_local.to_i
  
  holiday_start_time.each do |h|
    start_holiday = h
    end_holiday = h + 86400
    if  date_taken_int >= start_holiday && date_taken_int < end_holiday
      printf("[\"%s\",%d,%s,%s],\n", p["id"], 
             p["datetaken"].to_time.to_i,
             location["latitude"].to_s, location["longitude"].to_s)
      next
    end 
  end   
end
printf("];\n")


