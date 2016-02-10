#Vancouver Instagram 2015

## First get the data into mongo db:

1. . setupRTInstagram
2. backupPublicVancouverPhotosByDateTaken.rb 2015 1 1 2015 12 31

## Download the 150x150px thumbnails
3. mkdir THUMBNAIL_150x150
4. cd !$
5. ../download150x150-ig.rb

## Get the dominant colour of the valid images
not there are kludges ahead i.e. I’d do it differently if I did it again :-) :

1. ../getValidJpeg.rb >validjpegs.txt 2>2015-vancouver-instagram-invalidjpegs.txt #(have to remove mongodb error logging from these 2 files)
2. cat invalidjpegs.txt | ../markInvalid.rb
3. ../markInvalid.rb 2015-vancouver-instagram-invalidjpegs.txt
4. ../markValidAndSaveTop5Colours.rb validjpegs.txt
5. ../addDateTakenToExtraMetadata.rb # this is a kludge for convenience not needed really!
6. ../getDominantColourInBuckets.rb

