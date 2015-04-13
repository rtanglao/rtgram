#!/usr/bin/env ruby
require 'chunky_png'
require 'pp'
image = ChunkyPNG::Image.from_file('ig-vancouver-2014-topcolour-tiled-vertically.png')
working_image = image.dup

colour_hash = Hash.new(0)
working_image.pixels.map! do |pixel|
  rgbcolour = 65536 * ChunkyPNG::Color.r(pixel) + 256 *  ChunkyPNG::Color.g(pixel) +
              ChunkyPNG::Color.b(pixel)
  $stderr.printf("rgb in hex:%6X\n", rgbcolour)
  if colour_hash.has_key?(rgbcolour)
    colour_hash[rgbcolour] += 1
  else
    colour_hash[rgbcolour] = 1
  end
end
sorted_colour_array = colour_hash.sort_by {|k,v| v}.reverse
pp sorted_colour_array[0..9]
