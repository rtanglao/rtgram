#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'mongo'

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


photosExtraMetadata = db[:photosExtraMetadata]
photosColl = db[:photos]

photosExtraMetadata.\
  find({"valid150x150jpg" => true },
       :fields => ["datetaken", "id", "top_colour"]).\
  sort({"datetaken" => 1}).each do |extra_photo_metadata|
  id = extra_photo_metadata["id"]

  photo = photosColl.find({ "id" => id}).\
          projection({ "id" => 1, "location" => 1}).limit(1).first()
  printf("%s,%d,%d,%d,%d,%f,%f\n",
         id, extra_photo_metadata["datetaken"].to_i,
         extra_photo_metadata["top_colour"]["red"],
         extra_photo_metadata["top_colour"]["blue"],
         extra_photo_metadata["top_colour"]["green"],
         photo["location"]["latitude"],
         photo["location"]["longitude"])
end
