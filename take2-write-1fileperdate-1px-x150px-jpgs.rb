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

photosExtraMetadata = db[:photosExtraMetadata]

min_date = Time.local(2015,1,1, 0, 0)
max_date = Time.local(2015,1,1, 23, 59)

IO.foreach("1pxX150px-jpgs.txt") do |line|
  pp line
  id_regex=/[0-9]+-(?<id>[0-9_]+)-/
  parts = line.match(id_regex)
  id = parts['id']
  query = {}
  query["id"] = {"$eq" => id}
  photo = photosExtraMetadata.find(
    query).projection({"datetaken" => 1,
                       "id"=> 1}).limit(1).first()
  datetaken = photo["datetaken"].localtime
  filename_str = datetaken.strftime("%j_%a%b%-d") + "-1px-slices.txt"
  pp filename_str
  File.open(filename_str, 'a') { |f| f.write(line) }
end

