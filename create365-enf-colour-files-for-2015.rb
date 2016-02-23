#!/usr/bin/env ruby
require 'rubygems'
require 'open3'

date = Time.local(2015, 1, 1, 0, 0) # may want Time.utc if you don't want local time
for day_number in 1..365 do
  month = date.month.to_s
  day = date.mday.to_s
  stdout, stderr, status = Open3.capture3("../specificDateWriteEricFischerDatamapsColourFormat.rb 2015 " + month + " " + day + " 2015 " +  month + " " + day )
  file_number = sprintf("%3.3d", day_number)
  File.open(file_number + '-2015-'+ month + "-" + day +
            "-ig-vancouver-topcolour.enfformat", 'w') { |file| file.write(stdout) }
  date += 60 * 60 * 24
end

