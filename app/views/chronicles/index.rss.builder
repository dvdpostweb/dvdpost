xml.instruct! :xml, :version =>"1.0"
xml.rss :version => "2.0" do
    xml.channel do
    xml.title "Chronicles de Nina"
    xml.description "Ensemble des Articles"
    xml.link chronicles_url()
    
    for article in @chronicles
      post = article.contents.by_language(I18n.locale).first
      xml.item do
        xml.title "Les Chroniques de Nina : #{post.title}"
        xml.image article.cover.url(:small)
        xml.description post.description
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.link chronicle_url(:id => article.to_param)
     end
    end
  end
end