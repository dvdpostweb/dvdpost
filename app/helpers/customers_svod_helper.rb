module CustomersSvodHelper
  def svod_title(user)
    case user.svod_adult
      when 0
        'activate'
      when 1
        'deactivate'
      when 2
        'deactivate'
      when 3
        'reprendre votre abo'
      when 4
        'reprendre votre abo'
    end
      
  end
end
