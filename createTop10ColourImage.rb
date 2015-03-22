#!/usr/bin/env ruby
require 'rubygems'
require 'RMagick'

TOP_N = 10           # Number of swatches

# Create a 1-row image that has a column for every color in the quantized
# image. The columns are sorted decreasing frequency of appearance in the
# quantized image.
def sort_by_decreasing_frequency(img)
  hist = img.color_histogram
  # sort by decreasing frequency
  sorted = hist.keys.sort_by {|p| -hist[p]}
  new_img = Magick::Image.new(hist.size, 1)
  new_img.store_pixels(0, 0, hist.size, 1, sorted)
end

def get_pix(img)
  palette = Magick::ImageList.new
  pixels = img.get_pixels(0, 0, img.columns, 1)
  pixels.each do |p|
    puts p.to_color(Magick::AllCompliance, false, 8, true)
  end
end

original = Magick::Image.read("https://secure.gravatar.com/avatar/d0ed69be1d61caf4ddbdc74ce27788ff.png?s=200").first

# reduce number of colors
quantized = original.quantize(TOP_N, Magick::RGBColorspace)

# Create an image that has 1 pixel for each of the TOP_N colors.
normal = sort_by_decreasing_frequency(quantized)
normal.write("top10test.jpg")
