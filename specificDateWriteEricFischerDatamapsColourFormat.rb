#!/usr/bin/env ruby
require 'rubygems'
require 'pp'
require 'mongo'

def getH(r, g, b)
  h = 0
  s = 0
  v = 0
  
  min = r < g ? r : g
  min = min  < b ? min  : b

  max = r > g ? r : g
  max = max  > b ? max  : b
  
  v = max                       # v
  delta = max - min
  if (delta < 0.00001)
    s = 0
    h = 0 # undefined, maybe nan?
    return 0 # grey?!? return 0 which is red??!?
  end
  if( max > 0.0 ) # NOTE: if Max is == 0, this divide would cause a crash
    s = (delta / max)                  # s
  else 
    s = 0.0
    h = 255                            # its now undefined
    return h
  end
  if( r >= max )                           # > is bogus, just keeps compilor happy
    h = ( g - b ) / delta        # between yellow & magenta
  elsif( g >= max )
    h = 2.0 + (b - r ) / delta  # between cyan & yellow
  else
    h = 4.0 + ( r - g ) / delta  # between magenta & cyan
  end

  h *= 60.0                             # degrees

  if( h < 0.0 )
    h += 360.0
  end

  return h
end
  
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
  h = getH(extra_photo_metadata["top_colour"]["red"],
           extra_photo_metadata["top_colour"]["blue"],
           extra_photo_metadata["top_colour"]["green"])
  next if photo["location"]["latitude"].nil?
  printf("%f,%f :%d\n",
         photo["location"]["latitude"],
         photo["location"]["longitude"], (h*0.7083333333).round) # need value between 0 and 255 not 360!
end
