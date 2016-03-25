#!/usr/bin/env ruby
require 'rubygems'
require 'open3'

ARGV.each do |line|
  filename = line.chomp
  puts filename
  number_of_photos = %x{wc -l '#{filename}'}.to_i
  printf("number of photos:%d\n", number_of_photos)
  stdout, stderr, status = Open3.capture3(
                    "gm montage -tile " +
                    number_of_photos.to_s + "x1" +
                    " +frame +shadow +label -adjoin -geometry '1x150+0+0<' "+
                    "@" + filename + " 2015_DAILY_BARCODES/" +
                    File.basename(filename, ".txt") + ".png" )
  puts stderr
end
