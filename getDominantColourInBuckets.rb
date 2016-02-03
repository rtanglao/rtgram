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
current_bucket = Time.new(2015, 1, 1, 0, 0, 0, "-08:00") 
next_bucket = current_bucket + 240 # 4 minute bucket size
match = { '$match' =>
          {"valid150x150jpg" => true, 'datetaken' =>
                                      { '$gte' => current_bucket,
                                        "$lt" => next_bucket } }}
red_green_blue_divide_by_100 =
  { '$project' =>
    { 
      "red" =>
      { "$divide" => ["$top_colour.red", 255.0]},
      "green" =>
      { "$divide" => ["$top_colour.green", 255.0]},
      "blue" =>
      { "$divide" => ["$top_colour.blue", 255.0]}
    }
  }
red_green_blue_pow_22 =
  { '$project' =>
    {
      "redpow" =>
      { "$pow" => ["$red", 2.2]},
      "greenpow" =>
      { "$pow" => ["$green", 2.2]},
      "bluepow" =>
      { "$pow" => ["$blue", 2.2]}
    }
  }
red_green_blue_avg =
  { '$group' =>
    {
      "_id" => nil,
      "red_linear_avg" => { "$avg" => "$redpow" },
      "green_linear_avg" => { "$avg" => "$greenpow" },
      "blue_linear_avg" => { "$avg" => "$bluepow" }
    }
  }

g1 = { "$group" => { "_id" => {"powlinear" => { "$pow" => [ "$linear", 2.2]}}}}
# g1 = { '$group' =>
#        {"_id" => "id",
#         "linear" => {"$divide" => ["$top5colours[0][0]",
#                                                        255.0]}}}
# group = { '$group' =>
#           {"_id" => "id",
#            { "$avg" => { "$pow" => [
#                            {"$divide" => ["top5colours[0][0]",
#                                                        255.0]},
#                            2.2 ]}}}}
x = photosExtraMetadata.aggregate(
  [match, red_green_blue_divide_by_100,
   red_green_blue_pow_22,
   red_green_blue_avg
     # {
     #   "$group" =>
     #     {
     #       "_id" => { "$avg" => { "$pow" => [ {"$divide" => ["$top5colours[0][0]",255.0] }, 2.2 ]}}
     #     }
     # }
     ]
   )
pp x
x.each do |p|
  pp p
end


