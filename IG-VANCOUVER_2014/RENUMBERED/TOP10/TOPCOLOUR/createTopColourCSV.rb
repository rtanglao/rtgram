#!/usr/bin/env ruby
require 'oily_png'
require 'pp'
allcolours_png = ChunkyPNG::Image.from_file('ig-vancouver-2014-topcolour-tiled-vertically.png')

colour_hash = Hash.new(0)
allcolours_png.pixels.map! do |pixel|
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
$stderr.printf("number of colours:%d\n", sorted_colour_array.length)
old_pixel_x_position = 0
old_pixel_y_position = 0
new_png = ChunkyPNG::Image.new(1920, 989, ChunkyPNG::Color::TRANSPARENT)
printf "colour,count\n"
sorted_colour_array.each do |colour|
  colour_rgb = colour[0]
  colour_count = colour[1]
  printf("%6X,%d\n", colour_rgb, colour_count)
end
