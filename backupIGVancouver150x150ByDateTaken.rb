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

MONGO_HOST = ENV["MONGO_HOST"]
raise(StandardError,"Set Mongo hostname in ENV: 'MONGO_HOST'") if !MONGO_HOST
MONGO_PORT = ENV["MONGO_PORT"]
raise(StandardError,"Set Mongo port in ENV: 'MONGO_PORT'") if !MONGO_PORT
MONGO_USER = ENV["MONGO_USER"]
# raise(StandardError,"Set Mongo user in ENV: 'MONGO_USER'") if !MONGO_USER
MONGO_PASSWORD = ENV["MONGO_PASSWORD"]
# raise(StandardError,"Set Mongo user in ENV: 'MONGO_PASSWORD'") if !MONGO_PASSWORD
FLICKR_DB = ENV["INSTAGRAM_DB"]
raise(StandardError,"Set Mongo flickr database name in ENV: 'FLICKR_DB'") if !FLICKR_DB


db = Mongo::Connection.new(MONGO_HOST, MONGO_PORT.to_i).db(FLICKR_DB)
if MONGO_USER
  auth = db.authenticate(MONGO_USER, MONGO_PASSWORD)
  if !auth
    raise(StandardError, "Couldn't authenticate, exiting")
    exit
  end
end

photosColl = db.collection("photos")

def  renumber(filename, file_number)
  renumbered_filename = sprintf("RENUMBERED/%7.7d", file_number) + ".jpg"
  $stderr.printf("ln -s %s %s\n", filename, renumbered_filename)
  if !File.exist?(renumbered_filename)
    $stderr.printf("Renumbered file does not exist, renaming\n")
    File.symlink("../" + filename, renumbered_filename)
  else
      $stderr.printf("Renumbered file DOES exist, NOT renaming\n")
  end
end

def fetch_1_at_a_time(urls)

  easy = Curl::Easy.new
  easy.follow_location = true
  file_number = 0

  urls.each do|url|
    easy.url = url
    uri = URI.parse(url)
    filename = uri.path.rpartition('/')[2]
    $stderr.print "filename:'#{filename}'"
    $stderr.print "url:'#{url}' :"
    if File.exist?(filename)
      if File.stat(filename).size != 3635
        $stderr.printf("skipping EXISTING filename:%s\n", filename)
        file_number += 1
        renumber(filename, file_number)
        next
      else
        $stderr.printf("REFETCHING EXISTING 3635 length filename:%s\n", filename)
        File.unlink(filename)
      end
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
    file_number += 1
    renumber(filename, file_number)
  end
end

urls = []
query = {}
metrics_start = Time.utc(ARGV[0], ARGV[1], ARGV[2], 0, 0)
metrics_stop = Time.utc(ARGV[3], ARGV[4], ARGV[5], 23, 59, 59)
metrics_stop += 1
query = {"datetaken" => {"$gte" => metrics_start, "$lt" => metrics_stop}}

photosColl.find(query,
                  :fields => ["datetaken", "url_sq", "id", "images"]
                ).sort([["datetaken", Mongo::ASCENDING]]).each do |p|
  $stderr.printf("photo:%d, datetaken:%s\n", p["id"], p["datetaken"].to_s)
  if p["images"]["thumbnail"]["width"] == 150
    url_150x150 = p["images"]["thumbnail"]["url"]
    $stderr.printf("pushing 150x150:%s\n", url_150x150 )
    urls.push(url_150x150) if !url_150x150.nil?
  else
    $stderr.printf("non standard width url:%s width:%d\n", url_150x150, p["images"]["thumbnail"]["width"])
  end
end

$stderr.printf("FETCHING:%d 150x150 thumbnails\n", urls.length)

fetch_1_at_a_time(urls)

