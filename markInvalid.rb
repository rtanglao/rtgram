#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
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
Mongo::Logger.logger.level = ::Logger::FATAL # http://stackoverflow.com/questions/30292100/how-can-i-disable-mongodb-log-messages-in-console

photosExtraMetadata = db[:photosExtraMetadata]
photosColl = db[:photos]

ARGF.each do |invalid_jpeg_filename|
  m1 = /^\d{7}-(\w+)-/.match(invalid_jpeg_filename)
  instagram_id =m1[1]
  next if instagram_id.nil?
  $stderr.puts instagram_id if !instagram_id.nil?
  photo = photosColl.find({ "id" => instagram_id}).\
          projection({ "id" => 1}).limit(1).first()
  next if photo.nil?
  id = photo["id"]
  $stderr.printf("id found:%s\n", id)
  extraMetadata = { "valid150x150jpg" => false, "id" => instagram_id}
  photosExtraMetadata.find({ 'id' => instagram_id }).\
    update_one(extraMetadata,:upsert => true )
end
