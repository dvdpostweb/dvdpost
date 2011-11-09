class RemoteLinkRenderer < WillPaginate::LinkRenderer
  def prepare(collection, options, template)
    @remote = options.delete(:remote) || {}
    super
  end

protected
  def page_link(page, text, attributes = {})
    if @remote[:url] =~ /\?/
      sep = '&'
    else
      sep = '?'
    end
    @template.link_to(text, "#{@remote[:url]}#{sep}#{@remote[:param_name]}=#{page}", attributes)
  end
end