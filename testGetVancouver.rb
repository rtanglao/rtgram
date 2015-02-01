#!/usr/bin/env ruby
require 'rubygems'
require 'json'
require 'pp'
require 'time'
require 'date'
require 'parseconfig'
require './getInstagramResponse.rb'

instagram_config = ParseConfig.new('instagram.conf').params
client_id = instagram_config['client_id']
url = 'media/search/'
url_params = {
  :client_id => client_id,
  :lat => "49.260", # source: http://code.flickr.net/2008/09/04/whos-on-first/
  :lng => "-123.113"
}
vancouver_photos = getInstagramResponse(url, url_params)
pp vancouver_photos
