#!/usr/bin/env ruby
require 'rubygems'
require 'RMagick'
require 'isJPEG.rb'

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

file_number = 0
num_successful = 0
number_skipped = 0

while TRUE

  file_number += 1
  filename = sprintf("%7.7d", file_number) + ".jpg"
  top10_filename = "TOP10/" + sprintf("%7.7d-top10", file_number) + ".jpg"

  $stderr.printf("original:%s top10:%s\n", filename, top10_filename)
  if File.exist?(top10_filename)
    $stderr.printf("Renumbered file DOES exist, NOT re-creating:%s\n",
                   top10_filename)
    next
  end
  if !isJPEG(filename)
    number_skipped += 1
    $stderr.printf("skipping NON JPEG:%s, %d skipped\n", filename, 
                   number_skipped)
    next
  end
  skip = false
  begin
    original = Magick::Image.read(filename).first 
  rescue Magick::ImageMagickError
    skip = true
  end
  if skip
    $stderr.printf("ImageMagick ERROR in:%s\n", filename)
    next
  else
    num_successful += 1
  end
  
  $stderr.printf("CREATING:%s\n",top10_filename)

  quantized = original.quantize(TOP_N, Magick::RGBColorspace)

  top10 = sort_by_decreasing_frequency(quantized)
  top10.write(top10_filename)

end
$stderr.printf("sucessful:%\n", num_successful)
