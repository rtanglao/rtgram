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
  :lat => "49.25",
  :lng => "-123.11"
}
vancouver_photos = getInstagramResponse(url, url_params)
pp vancouver_photos
