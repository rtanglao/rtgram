find . -maxdepth 1 -name ‘*.jpg’ -print0 | xargs -0 -I file gm convert -crop 1x1+0+0 file TOPCOLOUR/file
