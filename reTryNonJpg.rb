#!/usr/bin/env ruby
require 'rubygems'
require 'mongo'
require 'pp'
require 'curb'

def isJPEG(filename)
  mimetype = IO.popen(["file", "--brief", "--mime-type", filename], in: :close, err: :close) { |io| io.read.chomp }
  if mimetype == "image/jpeg"
    return true
  else
    return false
  end
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
raise(StandardError,"Set Mongo flickr database name in ENV: 'INSTAGRAM_DB'") if !INSTAGRAM_DB

db = Mongo::Connection.new(MONGO_HOST, MONGO_PORT.to_i).db(INSTAGRAM_DB)
if MONGO_USER
  auth = db.authenticate(MONGO_USER, MONGO_PASSWORD)
  if !auth
    raise(StandardError, "Couldn't authenticate, exiting")
    exit
  end
end

photosColl = db.collection("photos")

Dir.foreach('.') do |filename|
  ending = filename[-3..-1] || filename
  next if filename == '.' or filename  == '..' or ending != 'jpg'
  $stderr.printf("checking jpeg:%s\n", filename)
  next if isJPEG(filename)
  $stderr.printf("NOT a JPEG:%s REFETCHING\n", filename)
  url_fragment = filename[0..-5]
  query = {"images.thumbnail.url" => /#{url_fragment}/i}
  photo = photosColl.find_one(query, :fields => ["images"])
  pp photo
  easy = Curl::Easy.new
  easy.follow_location = true
  easy.url = photo["images"]["thumbnail"]["url"]
  $stderr.printf("REFETCHING URL:%s\n", easy.url)

  File.open(filename, 'wb') do|f|
    easy.on_progress {|dl_total, dl_now, ul_total, ul_now| $stderr.print "="; true }
    easy.on_body {|data| f << data; data.size }   
    easy.perform
    $stderr.puts "=> '#{filename}'"
  end
end

