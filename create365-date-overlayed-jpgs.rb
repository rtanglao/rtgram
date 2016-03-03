#!/usr/bin/env ruby
require 'rubygems'
require 'open3'

date = Time.local(2015, 1, 1, 0, 0) # may want Time.utc if you don't want local time
day_number = 0
Dir.glob('/Users/rtanglao/Dropbox/GIT/rtgram/2015-IG-VAN-365-ENF-DATAMAPS-P50-PNGS/INCREASED_BRIGHTNESS/RESIZED1920/1920-*-increased-brightness-contrast-ig-vancouver-topcolour.jpg') do | jpg_file |
  day_number += 1
  puts jpg_file
  time_str = date.strftime("%A_%b_%-d_%Y")
  new_file_name = sprintf("%3.3d-%s", day_number, time_str) + ".jpg"
  puts new_file_name
  puts time_str
  stdout, stderr, status = Open3.capture3(
                    "convert -verbose -font Times-Bold -pointsize 32 " +
                    jpg_file +
                    " -fill white  -undercolor '#00000080' " +
                    "-gravity southeast -annotate +0+5 '" +
                    time_str + "'" +
                    " " +
                    "ANNOTATED_WITH_DATE/" + new_file_name)
  print stderr      
  date += 60 * 60 * 24
end
