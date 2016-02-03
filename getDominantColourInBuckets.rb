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
match = { '$match' => {"valid150x150jpg" => true, 'datetaken' => { '$gte' => current_bucket, "$lt" => next_bucket } }}
sort1 = { "$sort" =>  {"datetaken" => 1 } }
slicetopcolour = { "$project" =>
                   { "firstTopColour" =>
                     { "$slice" => [ "$top5colours", 1 ] }}}
sliceR = { "$project" =>
           { "firstR" =>
             { "$slice" => [ "$firstTopColour", 1 ] }}}
sliceRR = { "$project" => { "firstRR" => { "$slice" => [ "$firstR", 1 ] }}}
# project = {"$project" => {"id" => 1, "top5colours" => 1}}
slice1 = { "$slice" =>["top5colours", 0,1]}
u1 = {"$unwind" => "$top5colours"}
#project = {"$project" => {"linear" => { "$divide" => [ "$top5colours[0][0]", 255.0 ]}}}

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
     [match, sort1, slicetopcolour#, sliceR#, sliceRR#, slice1#,project #, g1
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
# r, g, b = 0.0, 0.0, 0.0
# number_samples_in_bucket = 0

# photosExtraMetadata.find({"valid150x150jpg" => true}).sort({ "datetaken" => 1}).each do
#   |photo|
#   id = photo["id"]
#   datetaken = photo["datetaken"]
#   if datetaken >= next_bucket
#     if number_samples_in_bucket == 0
#       printf("#0000\n")
#       r, g, b = 0.0, 0.0, 0.0
#       current_bucket = next_bucket
#       next_bucket += 240
#     end
#   dominant_colour_array = photo["top5colours"][0]
#   next if dominant_colour_array.nil?
#   $stderr.printf("id:%s datetaken:%s\n", id, datetaken.to_s)
# end
