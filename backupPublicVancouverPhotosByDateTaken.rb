#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'time'
require 'date'
require 'parseconfig'
require './getInstagramResponse.rb'
require 'pp'
require 'time'
require 'date'
require 'mongo'

instagram_config = ParseConfig.new('instagram.conf').params
client_id = instagram_config['client_id']

if ARGV.length < 6
  puts "usage: #{$0} yyyy mm dd yyyy mmm dd" #start date end date
  exit
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
raise(StandardError,"Set Mongo instagram database name in ENV: 'INSTAGRAM_DB'") if !INSTAGRAM_DB

db = Mongo::Client.new([MONGO_HOST], :database => INSTAGRAM_DB, :port => MONGO_PORT)
if MONGO_USER
  auth = db.authenticate(MONGO_USER, MONGO_PASSWORD)
  if !auth
    raise(StandardError, "Couldn't authenticate, exiting")
    exit
  end
end

url = 'media/search/'
photosColl = db[:photos]
photosColl.indexes.create_one({ "id" => -1 }, :unique => true)
MIN_DATE = Time.local(ARGV[0].to_i, ARGV[1].to_i, ARGV[2].to_i, 0, 0) # may want Time.utc if you don't want local time
MAX_DATE = Time.local(ARGV[3].to_i, ARGV[4].to_i, ARGV[5].to_i, 23, 59, 59) # may want Time.utc if you don't want local time

min_taken_date  = MIN_DATE
max_taken_date  = MAX_DATE - 1
number_of_days_done = 0
begin
  previous_max_date = Time.at(0)
  exit_this_date = false
  # 1st   6:59:50 aka 11:59:50p.m.
  # 100th 6:37:37 aka 11:37p.m.
  # Therefore take min time ie. the time of the 100th photo in this case and use that as max time
  $stderr.printf("min_taken:%s max_taken:%s\n", min_taken_date, max_taken_date)
  min_taken_date_from_instagram = MAX_DATE
  while max_taken_date > MIN_DATE && !exit_this_date
    min_taken_date_str = min_taken_date.to_i.to_s
    max_taken_date_str = max_taken_date.to_i.to_s
    url_params = {
      :client_id => client_id,
      :lat => "49.260", # source: http://code.flickr.net/2008/09/04/whos-on-first/
      :lng => "-123.113",
      :distance => "5000",
      :min_timestamp => min_taken_date_str,
      :max_timestamp => max_taken_date_str,
      :count => 100
    }
    vancouver_photos = getInstagramResponse(url, url_params)
    if vancouver_photos.nil?
      break
    end
    if vancouver_photos["meta"]["code"] != 200
      $stderr.printf("meta.code:%d\n", vancouver_photos["meta"]["code"])
      break
    end
    if vancouver_photos.has_key?("pagination")
      $stderr.printf("pagination: next_url:%s next_max_id:%s\n", 
                     vancouver_photos["pagination"]["next_url"], 
                     vancouver_photos["pagination"]["next_max_id"])
    end
    vancouver_photos["data"].each do|photo|
      $stderr.printf("created_time:%s\n", photo["created_time"])
      datetaken = Time.at(photo["created_time"].to_i)
      datetaken = datetaken.utc
      $stderr.printf("PHOTO datetaken:%s\n", datetaken)
      photo["datetaken"] = datetaken
      if datetaken < min_taken_date_from_instagram
        min_taken_date_from_instagram = datetaken
      end
      id = photo["id"]
      photosColl.find({ 'id' => id }).update_one(
        photo,:upsert => true )
    end

    # min_taken_date += (60 * 60 * 24)
    max_taken_date = min_taken_date_from_instagram
    $stderr.printf("END of API photo loop: max_taken_date:%s previous_max_date:%s\n",
                   max_taken_date, previous_max_date)
    if previous_max_date != Time.at(0)
      if previous_max_date == max_taken_date
        exit_this_date = true
        # $stderr.printf("setting exit_this_date to TRUE\n")
      else
        # $stderr.printf("LEAVING exit_this_date set to FALSE\n")
      end
    end
    previous_max_date = max_taken_date    
  end
  number_of_days_done += 1
  max_taken_date = MAX_DATE - ((60 * 60 * 24) * number_of_days_done)
  $stderr.printf("END of DAY photo loop: max_taken_date:%s, MIN_DATE:%s\n", max_taken_date, MIN_DATE)
end while max_taken_date > MIN_DATE
# pp vancouver_photos
