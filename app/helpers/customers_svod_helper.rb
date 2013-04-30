module CustomersSvodHelper
  def svod_title(user)
    case user.svod_adult
      when 0
        '.activate'
      when 1
        '.deactivate'
      when 2
        '.deactivate'
      when 3
        '.break'
      when 4
        '.break'
    end
      
  end
end
