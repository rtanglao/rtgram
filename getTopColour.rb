#!/usr/bin/env ruby
require 'rubygems'
require 'pp'
require 'miro'

Dir.glob('*.jpg') do |jpg_file|
  colors3 = Miro::DominantColors.new(jpg_file)
  mimetype = `file -Ib #{jpg_file}`.gsub(/\n/,"")
  if (mimetype <=> "image/jpeg; charset=binary") != 0
    next
  end
  printf("%s\n", colors3.to_hex[0])
end
