module ContestsHelper
  def question(contest)
    eval("contest.question_#{I18n.locale}")
  end

  def response(contest)
    eval("contest.choice_#{I18n.locale}").split('_')
  end

  def title(contest, extern='')
    extern + eval("contest.title_#{I18n.locale}") + extern
  end

  def big_title(contest)
    eval("contest.big_title_#{I18n.locale}")
  end

end
