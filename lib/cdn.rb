module CDN
  class << self
    def connect_url(token, source, language = 'fre', subtitle = nil)
      if source == StreamingProduct.source[:alphanetworks]
        url = "http://apache.alphanetworks.be/dvdpost/streaming/#{token}/flash/#{language}#{subtitle ? "/"+subtitle : ''}"
      else
        url = "rtmp://secureflash.cdnlayer.com/secure_dvstream/_definst_/?token=#{token}"
      end
      url
    end

    def source_file_regexp
      /(rtmp|rtmpt|rtmps):\/\/secureflash.cdnlayer.com\/secure_dvstream\/(_definst_\/|)(.*)\?token=.*/
    end
  end
end