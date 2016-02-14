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

