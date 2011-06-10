module CDN
  class << self
    def connect_url(token, source)
      if source == StreamingProduct.source[:alphanetworks]
        url = "rtmp://secureflash.cdnlayer.com/secure_dvstream/_definst_/?token=#{token}"
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