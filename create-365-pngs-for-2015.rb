#!/usr/bin/env ruby
require 'rubygems'
require 'open3'

Dir.glob('/Users/rtanglao/Dropbox/GIT/rtgram/2015-IG-VAN-365-ENF-DATAMAPS-DIRECTORIES/*-DIRECTORY') do |enf_directory|
  png = enf_directory.split('/')[-1].gsub(
    "-DIRECTORY", ".png")
  printf("png:%s directory:%s\n", png, enf_directory)
  stdout, stderr, status = Open3.capture3(
	"/Users/rtanglao/Dropbox/GIT/datamaps/render -p 20 -C256 -A -- " + enf_directory +
	" 16 49.25706 -123.070538525034 49.29808542 -123.159733" )
  print stderr
  File.open(png, 'w') { |file| file.write(stdout) }
end

