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
last_bucket =  Time.new(2016, 1, 1, 0, 0, 0, "-08:00") 
while next_bucket < last_bucket do
  match = { '$match' =>
            {"valid150x150jpg" => true, 'datetaken' =>
                                        { '$gte' => current_bucket,
                                          "$lt" => next_bucket } }}
  red_green_blue_divide_by_100_and_pow =
    { '$project' =>
      { 
        "red_pow" => { "$pow" => [{"$divide" => ["$top_colour.red", 255.0]}, 2.2]},
        "green_pow" => { "$pow" => [{"$divide" => ["$top_colour.green", 255.0]}, 2.2]},
        "blue_pow" => { "$pow" => [{"$divide" => ["$top_colour.blue", 255.0]}, 2.2]}
      }
    }

  red_green_blue_linear_avg =
    { '$group' =>
      {
        "_id" => nil,
        "red_linear_avg" => { "$avg" => "$red_pow" },
        "green_linear_avg" => { "$avg" => "$green_pow" },
        "blue_linear_avg" => { "$avg" => "$blue_pow" }
      }
    }
  red_green_blue_float_avg =
    { '$project' =>
      {
        "_id" => 0,
        "red_float_avg" => {
          "$multiply" =>
          [255.0, "$pow" => ["$red_linear_avg", 1.0/2.2]]},
        "green_float_avg" => {
          "$multiply" =>
          [255.0, "$pow" => ["$green_linear_avg", 1.0/2.2]]},
        "blue_float_avg" => {
          "$multiply" =>
          [255.0, "$pow" => ["$blue_linear_avg", 1.0/2.2]]}
      }
    }


  colour_collection = photosExtraMetadata.aggregate(
    [match, red_green_blue_divide_by_100_and_pow,
     red_green_blue_linear_avg,
     red_green_blue_float_avg
    ]
  )
  current_bucket = next_bucket
  next_bucket += 240 # 4 minute bucket size

  colour_array = colour_collection.to_a
  if colour_array.nil? || colour_array.length == 0
    $stderr.printf("no pics found in bucket:%s\n", (current_bucket - 240).to_s)
    printf("#0000\n")
    next
  end
  pp colour_array
  colour = colour_array[0]["red_float_avg"].round * 65536 +
           colour_array[0]["green_float_avg"].round * 256 +
           colour_array[0]["blue_float_avg"].round 
           
  printf("#%4.4x\n", colour)
end

# x.each do |p|
#   pp p
# end
# y= x.to_a
# pp y
# pp y[0]["green_float_avg"].round
# #pp x["blue_float_avg"]
