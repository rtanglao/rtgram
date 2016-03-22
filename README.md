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
2. ```cd 2015-IG-VAN-365-ENF-DATAMAPS_FILES```
3. ```../create365-enf-colour-files-for-2015.rb ```
4. ```cd ../Users/rtanglao/Dropbox/GIT/rtgram/2015-IG-VAN-365-ENF-DATAMAPS-DIRECTORIES```
5. ```../create365-encode-directories-for-2015 ```
1. make 365 pngs: 
```cd &lt;directory where you want the jpegs>; ../create-365-p50-pngs-for-2015.rb```
1. turn into animated GIF and video 
```gm convert -loop 50 -delay 20 *.png ig-2015-van-p50.gif```
```convert -format jpg *.png```
```mv *.jpg to another directory```
```run time lapse assembler```
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

## March 6, 2016
Theory: nil lat and long cause blank spots in maps
* theory is correct, here is the missing line in specificDateWriteEricFischerDatamapsColourFormat.rb:      
 
```next if photo["location"]["latitude"].nil?```
   
## March 7, 2016

```mogrify —path . -format jpg @365-ig-vancouver-topcolour-png-list.txt```

## March 8, 2016

1. make 1920 pixel wide jpgs in preparation for labelling with the date:  
```mkdir 1920; cd 1920; mogrify -resize 1920 -path . ../*.jpg ```
1. make annotated jpegs:
```mkdir ANNOTATED_WITH_DATE;~/Dropbox/GIT/rtgram/create365-v2-date-overlaid-jpgs.rb```

## March 9, 2016
1. use [montage “null:”](http://www.imagemagick.org/Usage/montage/#null) to make a day of the week graphic, i.e. instead of 61x61 have 52 rows for each week, the first week will have 3 null images for Monday-Wednesday since 2015 started on a Thursday so you need 53 rows:  

 ```sh
 gm montage -verbose -adjoin -tile 7x53 +frame +shadow\
 +label -adjoin -geometry '1920x1354+0+0<' null: null:\
 null: @365jpgs.txt null: null: null: \
 09march2016-53x7-365days-vancouver-instagram-2015-montage.png
 ```

## March 10 2016
1. Prepare CSV for mapping using GGMAP  
```./writeHexTopColourLatLonByDate.rb > 10March2016-instagram-vancouver-top-colour-lat-long-2015.csv```

## March 21 2016 - make a barcode
 ```sh
 cd /Users/rtanglao/Dropbox/GIT/rtgram ; mkdir THUMBNAIL_150x150; cd !$
 find .. -name '*.jpg' -print > 150x150jpgs.txt #ls doesn't work because there are too many files!
 cat 150x150jpgs.txt | xargs -n 1 mogrify -path . -resize 1x150\!
```

# Helpful emacs regular expressions

 1. to get rid of instagram ids:
     
         ^\[\”[0-9_]+\”, replace with [
         
 1. to get rid of ids:
     
         ^\[[0-9]+, replace with [
     

