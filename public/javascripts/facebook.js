FB.init({
				appId : "349706641706395",
				status : true,
				cookie : true
			});

			function postToFeed(text, image, locale, id, name, caption) {

				// calling the API ...
				var obj = {
					method : 'feed',
					link : 'http://public.dvdpost.com/'+locale+'/products/'+id,
					picture : image,
					name : name,
					caption : caption,
					description : text
				};

				function callback(response) {
					/*alert("Post ID: " + response['post_id']);*/
				}


				FB.ui(obj, callback);
			}