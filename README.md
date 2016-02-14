#Vancouver Instagram 2015

## First get the data into mongo db:

    1. . setupRTInstagram
    2. backupPublicVancouverPhotosByDateTaken.rb 2015 1 1 2015 12 31

## Download the 150x150px thumbnails
    3. mkdir THUMBNAIL_150x150
    4. cd !$
    5. ../download150x150-ig.rb

## Get the dominant colour of the valid images
NOTE: there are kludges ahead i.e. I’d do it differently if I did it again :-) :

1.  ../getValidJpeg.rb >validjpegs.txt 2>2015-vancouver-instagram-invalidjpegs.txt #(have to remove mongodb error logging from these 2 files), get results in instagram data for vancouver photos in a mongodb structured exactly like what you get from the instagram API    
2.  mkdir THUMBNAIL_150x150; cd !$ \../download150x150-ig.rb
3.  ../getValidJpeg.rb >validjpegs.txt 2>2015-vancouver-instagram-invalidjpegs.txt #get valid and in valid jpegs (some were deleted by users)
4.  ../markInvalid.rb 2015-vancouver-instagram-invalidjpegs.txt
5.  ../markValidAndSaveTop5Colours.rb validjpegs.txt
6.  ../addDateTakenToExtraMetadata.rb # this is a kludge for convenience!
7.  ../getDominantColourInBuckets.rb >04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.hexdump
8.  xxd -r -p  04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.hexdump 04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.raw
9.  convert -depth 8  -size 360x360 04feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.rgb 05feb2016-ig-vancouver-dominantcolour-4-minutebuckets-2015.png # open rawfile in photoshop or using imagemagick

