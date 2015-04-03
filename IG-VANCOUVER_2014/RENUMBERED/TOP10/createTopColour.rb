#!/usr/bin/env ruby
require 'rubygems'
require 'scanf'
require 'mini_magick'
#MiniMagick.configure do |config|
#  config.cli = :graphicsmagick
#  config.timeout = 5
#  #config.cli_path = "/usr/local/bin/"
#end
ARGF.each do |line|
  MiniMagick::Tool::Identify.new do |id|
    id << line
    id.verbose(true)
  # MiniMagick::Tool::Convert.new do |convert|
  #   file_number = line.scanf("%d").first
  #   file_str = sprintf("%7.7d", file_number)
  #   line = "./"+line
  #   convert << line
  #   convert.crop("1x1+0+0")
  #   convert.profile('"*"')
  #   convert << "TOPCOLOUR/"+ file_str + "-top-colour.png"
  end
end
