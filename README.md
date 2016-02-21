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
	5.  ./render -L 5 -C256 -A -- 20feb2016-instagram-vancouver-2015-topcolour 16 49.25706 -123.070538525034 49.29808542 -123.159733 > 20feb2016-L5-ig-vancouver-2015-colour.png
1. make 365 files
 1.  make 365 pngs 
 1.  turn into animated GIF and video   
    
# Helpful emacs regular expressions

     1. to get rid of instagram ids:
     
         ^\[\”[0-9_]+\”, replace with [
         
     1. to get rid of ids:
     
         ^\[[0-9]+, replace with [
     

