module CustomerSurveysHelper
  def item_title(survey, detail)
    case survey.survey_kind.to_param.to_i
      when 1
        detail.product.description.title if detail.product.description
      when 2
        detail.actor.name if detail.actor
      when 3
        detail.director.name if detail.director
      when 4
        t ".item#{survey.to_param}_#{detail.to_param}"
      else
        ''
    end
  end
end
