def isJPEG(filename)
  mimetype = IO.popen(["file", "--brief", "--mime-type", filename], in: :close, err: :close) { |io| io.read.chomp }
  if mimetype == "image/jpeg"
    return true
  else
    return false
  end
end
