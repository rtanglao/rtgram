#!/usr/bin/env ruby
require 'rubygems'
require 'open3'

ARGV.each do |line|
  filename = line.chomp
  stdout, stderr, status = Open3.capture3(
                    "gm montage -verbose -tile 1920x7 +frame +shadow +label" +
                    " -adjoin -geometry '1x150+0+0<' " + "@" + filename +
                    " " + filename + ".png"
                  )
  print stderr
end
