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
pp sorted_colour_array[0..9]
old_pixel_x_position = 0
old_pixel_y_position = 0
new_png = ChunkyPNG::Image.new(1920, 989, ChunkyPNG::Color::TRANSPARENT)
sorted_colour_array.each do |colour|
  colour_rgb = colour[0]
  colour_count = colour[1]
  pixels_until_end_of_line = 1920 - old_pixel_x_position
  b = colour_rgb & 255
  g = (colour_rgb >> 8) & 255
  r = (colour_rgb >> 16) & 255
  colour = ChunkyPNG::Color.rgb(r,g,b)
  if colour_count >= pixels_until_end_of_line
    new_pixel_position = old_pixel_x_position + pixels_until_end_of_line
    new_png.line(old_pixel_x_position, old_pixel_y_position, new_pixel_position-1, old_pixel_y_position,
                 colour)
    if new_pixel_position  == 1920
      old_pixel_x_position =  0
      old_pixel_y_position += 1
    else
      old_pixel_x_position = new_pixel_position
    end
    colour_count -= pixels_until_end_of_line
  end
  next if colour_count == 0
  
  if colour_count / 1920 > 0
    for i in 1..(colour_count / 1920)
      new_png.line(0, old_pixel_y_position, 1919, old_pixel_y_position,
                   colour)
      old_pixel_y_position += 1
    end

    old_pixel_x_position = 1920

    next if (colour_count % 1920) == 0
    new_pixel_position = colour_count % 1920
    new_png.line(0, old_pixel_y_position, new_pixel_position - 1, old_pixel_y_position,
                 colour)
  else
    new_pixel_position = old_pixel_x_position + colour_count
    new_png.line(old_pixel_x_position, old_pixel_y_position, new_pixel_position - 1, old_pixel_y_position, 
                 colour)
    old_pixel_y_position += 1 if colour_count == 1920
  end
  old_pixel_x_position = new_pixel_position
end
new_png.save('arranged-by-frequent-colour-ig-vancouver-2014-topcolour-tiled-vertically.png')
