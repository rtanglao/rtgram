#Vancouver Instagram 2015

## First get the data into mongo db:

    . setupRTInstagram
    backupPublicVancouverPhotosByDateTaken.rb 2015 1 1 2015 12 31

## Download the 150x150px thumbnails
    mkdir THUMBNAIL_150x150
    cd !$
    ../download150x150-ig.rb

## Get the dominant colour of the valid images
NOTE: there are kludges ahead i.e. I’d do it differently if I did it again :-) :
 
    ../getValidJpeg.rb >validjpegs.txt 2>2015-vancouver-instagram-invalidjpegs.txt #get valid and in valid jpegs (some were deleted by users), also have to remove mongodb error logging from these 2 files
    ../markInvalid.rb 2015-vancouver-instagram-invalidjpegs.txt
    ../markValidAndSaveTop5Colours.rb validjpegs.txt
    ../addDateTakenToExtraMetadata.rb # this is a kludge for convenience!
    ../getDominantColourInBuckets.rb >04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.hexdump
    xxd -r -p  04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.hexdump 04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.raw
    convert -depth 8  -size 360x360 04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.rgb 05feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.png # open rawfile in photoshop or using imagemagick
    
# Making an Eric Fisher style map
   
    git clone https://github.com/ericfischer/datamaps.git
    cd datamaps
    make
    cat 15feb2015-ig-vancouver-2015-lat-lon.txt | ./encode -o instagram-vancouver-2015 -z16
    ./render -A -- instagram-vancouver-2015/ 16 49.25706 -123.070538525034 49.29808542 -123.159733 > ig-vancouver-2015.png
    
## Next Steps: 

1. convert specificDateWriteJSONTopColour.rb to make files with h values - DONE !
2. ./specificDateWriteEricFisherDatamapsColourFormat.rb 2015 1 1 2015 1 1 > 19feb2016-lat-long-h.enfformat
3. ./specificDateWriteEricFisherDatamapsColourFormat.rb 2015 1 1 2015 12 31 > 20feb2016-vancouver-2015-ig-lat-long-h.enfformat
4. cat ~/Dropbox/Git/rtgram/20feb2016-vancouver-2015-ig-lat-long-h.enfformat | ./encode -o 20feb2016-instagram-vancouver-2015-topcolour -z16 -m8
5. ./render -L 5 -C256 -A -- 20feb2016-instagram-vancouver-2015-topcolour 16 49.25706 -123.070538525034 49.29808542 -123.159733 > 20feb2016-L5-ig-vancouver-2015-colour.png
1. make 365 files
 cd &lt;directory with encode directories>;../create365-encode-directories-for-2015
1. make 365 pngs 
 cd &lt;directory where you want the jpegs>; ../create-365-p50-pngs-for-2015.rb
1. turn into animated GIF and video 
 gm convert -loop 50 -delay 20 *.png ig-2015-van-p50.gif
 convert -format jpg *.png
 mv *.jpg to another directory
 run time lapse assembler 
1. try brightening the jpgs using convert
2. Maybe make some music out of the data?!? http://www.cbc.ca/radio/spark/296-sleep-secrets-drone-danger-and-more-1.3265562/listen-to-the-music-this-man-makes-out-of-ordinary-data-1.3270839

## 28 feb 2016 

    convert -brightness-contrast 50x20 -format jpg ../*.png creates pngs in the current directory
    convert -brightness-contrast 50x20 ../*.png %03d-increased-brightness-contrast-ig-vancouver-topcolour.jpg #otherwise it puts it in a different directory i.e. ..
    convert -background white -alpha remove -layers optimize-plus -delay 15x60 -resize 800 *.jpg -loop 0
### small multiples:

    gm montage -verbose -adjoin -tile 19x19 +frame +shadow +label -adjoin -geometry '4156x2930+0+0<' *.jpg 28feb2016-361-out-365days-vancouver-instagram-20150-montage.png
## 29feb 2016 

    rtanglao13483:INCREASED_BRIGHTNESS rtanglao$ convert 29feb2016-19x19-361-out-365days-vancouver-instagram-20150-montage.png 9feb2016-19x19-361-out-365days-vancouver-instagram-20150-montage.jpg
    convert: Maximum supported image dimension is 65500 pixels `9feb2016-19x19-361-out-365days-vancouver-instagram-20150-montage.jpg' @ error/jpeg.c/JPEGErrorHandler/322.

    mkdir RESIZED1920; cd !$
    convert -resize 1920 ../*.jpg 1920-%03d-increased-brightness-contrast-ig-vancouver-topcolour.jpg
    gm montage -verbose -adjoin -tile 19x19 +frame +shadow +label -adjoin -geometry '1920x1354+0+0<' @1920-361-ig-vancouver-jpgs.txt 29feb2016-1920-361-out-365days-vancouver-instagram-20150-montage.png

    convert -level 0%,100%,0.5 29feb2016-1920-361-out-365days-vancouver-instagram-20150-montage.png dark.5-gamma-29feb2016-1920-361-out-365days-vancouver-instagram-20150-montage.png

    rtanglao13483:RESIZED1920 rtanglao$ brew install ghostscript
==> Downloading https://homebrew.bintray.com/bottles/ghostscript-9.18.el_capitan
######################################################################## 100.0%
==> Pouring ghostscript-9.18.el_capitan.bottle.tar.gz
🍺  /usr/local/Cellar/ghostscript/9.18: 709 files, 61M

    convert -font Times-Bold  -pointsize 64 1920-361-increased-brightness-contrast-ig-vancouver-topcolour.jpg -fill white  -undercolor '#00000080' -gravity southeast  -annotate +0+5 'SorthEast' output.jpg 

## 02 March 2016
1. added rotated-3325x6279-100percent-saturation-1000percent-05feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015-low-quality.jpg which is used for custom shoes at zazzle and art of wear
	* [custom shoes from zazzle](http://www.zazzle.com/instagram_vancouver_2015_top_color_shoes_printed_shoes-256051822005766899)

## To annotate with date

    cd /Users/rtanglao/Dropbox/GIT/rtgram/2015-IG-VAN-365-ENF-DATAMAPS-P50-PNGS/INCREASED_BRIGHTNESS/RESIZED1920
    mkdir ANNOTATED_WITH_DATE
    
    ~/Dropbox/GIT/rtgram/create365-date-overlayed-jpgs.rb
    \# jpegs are “ddd-day_of_week_Month_day_year.jpg” e.g. 183-Thursday_Jul_2_2015.jpg
    
    cd ANNOTATED_WITH_DATE
    
    ls -1 | head -361 > 361-ig-vancouver-jpgs.txt
    gm montage -verbose -adjoin -tile 19x19 +frame +shadow +label -adjoin -geometry '1920x1354+0+0<' @361-ig-vancouver-jpgs.txt 02March2016–date-annotated-1920-361-out-365days-vancouver-instagram-20150-montage.jpg # (or .png)

## April 4, 2016 1p.m. UBC Talk

What should I present on? Maybe:

1. the crazy “unsupported” :-) instagram API 
2. MongoDB for API prototyping?
3. homage to Kip?
4. try some ggmap stuff?
4. etc ?
## April 6, 2016
* Theory: nil lat and long cause blank spots in maps
* missing line in specificDateWriteEricFischerDatamapsColourFormat.rb:    

   ```next if photo["location"]["latitude"].nil?```
 
# Helpful emacs regular expressions

 1. to get rid of instagram ids:
     
         ^\[\”[0-9_]+\”, replace with [
         
 1. to get rid of ids:
     
         ^\[[0-9]+, replace with [
     

