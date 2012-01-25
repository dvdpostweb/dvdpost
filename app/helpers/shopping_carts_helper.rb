module ShoppingCartsHelper
  def shipping(count)
  	if count == 0
			price = 0
		elsif count <= 2
			price = 2.80
		elsif count <= 12
			price = 6.7
		elsif count <= 24
			price = 12.4
		elsif count <= 37
			price = 19.1
		else
			price = 0.51 * count
		end
	end
end