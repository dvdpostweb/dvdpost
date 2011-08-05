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
        case I18n.locale
        when :en
          detail.free_text_en
        when :nl
          detail.free_text_nl
        else
          detail.free_text_fr
        end
      else
        ''
    end
  end
end
