module ThemesEventsHelper
  def get_path(theme)
    if theme.url
		  eval(theme.url)
	  else
		  theme_path(:id => theme.to_param)
	  end
  end
end
