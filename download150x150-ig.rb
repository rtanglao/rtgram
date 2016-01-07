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
require 'curb'

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


photosColl = db[:photos]

def fetch_1_at_a_time(urls_and_ids)
  
  i = 0
  
  easy = Curl::Easy.new
  easy.follow_location = true

  urls_and_ids.each do |u_and_i|
    i += 1
    url = u_and_i[:url]
    id = u_and_i[:id]
    easy.url = url
    uri = URI.parse(url)
    filename = sprintf("%7.7d-%s-%s", i, id, uri.path.rpartition('/')[2])
    $stderr.print "filename:'#{filename}'"
    $stderr.print "url:'#{url}' :"
    if File.exist?(filename)
      $stderr.printf("skipping EXISTING filename:%s\n", filename)
      next
    end
  try_count = 0
    begin
      File.open(filename, 'wb') do|f|
        easy.on_progress {|dl_total, dl_now, ul_total, ul_now| $stderr.print "="; true }
        easy.on_body {|data| f << data; data.size }   
        easy.perform
        $stderr.puts "=> '#{filename}'"
      end
    rescue Curl::Err::ConnectionFailedError => e
      try_count += 1
      if try_count < 4
        $stderr.printf("Curl:ConnectionFailedError exception, retry:%d\n",\
                       try_count)
        sleep(10)
        retry
      else
        $stderr.printf("Curl:ConnectionFailedError exception, retrying FAILED\n")
        raise e
      end
    end
  end
end

urls_and_ids = []

photosColl.find({},
                :fields => ["datetaken", "id", "images"]).
  sort(:datetaken => 1).each do |p|
  id = p["id"]
  $stderr.printf("photo:%s, datetaken:%s\n", p["id"], p["datetaken"].to_s)
  if p["images"]["thumbnail"]["width"] != 150 &&  p["images"]["thumbnail"]["height"] != 150
    $stderr.printf("thumbnail is NOT 150x150\n")
    next
  end
  urls_and_ids.push({ :url => p["images"]["thumbnail"]["url"], :id => id}) if !p["images"]["thumbnail"]["url"].nil?
end

fetch_1_at_a_time(urls_and_ids)

