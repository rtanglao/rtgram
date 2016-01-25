#!/usr/bin/env ruby
require 'rubygems'
require 'mini_magick'
require 'miro'

MiniMagick.configure do |config|
  config.cli = :graphicsmagick
end

Dir.glob('*.jpg') do |jpg_file|
  identify = MiniMagick::Tool::Identify.new
  identify << jpg_file
  id = identify.call
  if id.include? "JPEG"
    colors3 = Miro::DominantColors.new(jpg_file)
    printf("%s\n", colors3.to_hex[0])
  end
end
