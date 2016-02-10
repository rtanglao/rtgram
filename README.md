#Vancouver Instagram 2015

## First get the data into mongo db:

1. . setupRTInstagram
2. backupPublicVancouverPhotosByDateTaken.rb 2015 1 1 2015 12 31

## Then download the 150x150px thumbnails
3. mkdir THUMBNAIL_150x150
4. cd !$
5. ../download150x150-ig.rb
