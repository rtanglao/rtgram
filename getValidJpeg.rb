#!/usr/bin/env ruby
require 'rubygems'
require 'mini_magick'

MiniMagick.configure do |config|
  config.cli = :graphicsmagick
end

Dir.glob('*_n.jpg') do |jpg_file|
  begin
    image = MiniMagick::Image.open(jpg_file)
    puts jpg_file
  rescue MiniMagick::Invalid
    $stderr.puts jpg_file
  end
end
