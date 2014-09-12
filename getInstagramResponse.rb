require 'rubygems'
require 'typhoeus'
def getInstagramResponse(url, params)
  url = "https://api.instagram.com/v1/" + url
  result = Typhoeus::Request.get(url,
    :params => params )
  return JSON.parse(result.body)
end
