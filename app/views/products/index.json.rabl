collection @products
attributes :id, :media
node do |u|
  { :rating => u.rating(nil), :url => product_path(:id => u.to_param, :source => 55), :add_url => new_wishlist_item_path(:product_id => u.to_param, :source => 55) }
end
attributes :products_type, :if => lambda { |m| m.in_streaming? }
node(:streaming_url, :if => lambda { |m| m.in_streaming? }) do |m|
  new_product_token_path(:product_id => m.to_param, :source => 55)
end
node(:trailer_url, :if => lambda { |m| m.trailer? }) do |m|
  product_trailer_path(:product_id => m.to_param)
end

child :description, :object_root => false do
  attributes :title, :text, :image
end
child :actors, :object_root => false do
  attributes :name
  node do |u|
    { :url => actor_products_path(:actor_id => u.to_param, :source => 55) }
  end
end
child :director do
  attributes :name
  node do |u|
    { :url => director_products_path(:director_id => u.to_param, :source => 55) }
  end
end
child :public do
  attributes :description, :id
end
child :languages, :object_root => false do
  attributes :id, :short, :name
end
child :subtitles, :object_root => false do
  attributes :id, :short, :name
end
