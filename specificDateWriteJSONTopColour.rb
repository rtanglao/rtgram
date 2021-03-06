#!/usr/bin/env ruby
require 'rubygems'
require 'pp'
require 'mongo'

Mongo::Logger.logger.level = ::Logger::FATAL # http://stackoverflow.com/questions/30292100/how-can-i-disable-mongodb-log-messages-in-console


if ARGV.length < 6
  puts "usage: #{$0} yyyy mm dd yyyy mmm dd"
  exit
end

MIN_DATE = Time.local(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i, 0, 0) # may want Time.utc if you don't want local time
MAX_DATE = Time.local(ARGV[3].to_i, ARGV[4].to_i, ARGV[5].to_i, 23, 59) # may want Time.utc if you don't want local time

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


photosExtraMetadata = db[:photosExtraMetadata]
photosColl = db[:photos]

printf("instagram_vancouver_top_colour_%d_%d_%d_%d_%d_%d=[\n",
       MIN_DATE.year, MIN_DATE.month, MIN_DATE.mday,
       MAX_DATE.year, MAX_DATE.month, MAX_DATE.mday)
query = {}
query["datetaken"] = {"$gte" => MIN_DATE, "$lte" => MAX_DATE}
query["valid150x150jpg"] = true
photosExtraMetadata.\
  find(query,
       :fields => ["datetaken", "id", "top_colour"]).\
  sort({"datetaken" => 1}).each do |extra_photo_metadata|
  id = extra_photo_metadata["id"]

  photo = photosColl.find({ "id" => id}).\
          projection({ "id" => 1, "location" => 1}).limit(1).first()
  printf("[\"%s\",%d,%d,%d,%d,%f,%f],\n",
         id, extra_photo_metadata["datetaken"].to_i,
         extra_photo_metadata["top_colour"]["red"],
         extra_photo_metadata["top_colour"]["blue"],
         extra_photo_metadata["top_colour"]["green"],
         photo["location"]["latitude"],
         photo["location"]["longitude"])
end
printf("];\n")
