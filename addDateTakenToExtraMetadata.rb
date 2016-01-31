#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'mongo'
require 'miro'

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
Mongo::Logger.logger.level = ::Logger::FATAL # http://stackoverflow.com/questions/30292100/how-can-i-disable-mongodb-log-messages-in-console

photosExtraMetadata = db[:photosExtraMetadata]
photosColl = db[:photos]
Miro.options[:color_count] = 5

photosColl.find().projection({ "id" => 1, "datetaken" => 1}).each{
  |photo|
  id = photo["id"]
  datetaken = photo["datetaken"]
  $stderr.printf("id:%s datetaken:%s\n", id, datetaken.to_s)
  extraMetadata = photosExtraMetadata.find({ "id" => id}).limit(1).first()
  extraMetadata["datetaken"] = datetaken
  photosExtraMetadata.find({ 'id' => id }).update_one(extraMetadata )
}
