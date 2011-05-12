class SurveysController < ApplicationController
  def show
    @survey = Survey.find(params[:id])
    @details = @survey.survey_details.ordered
    @best = @survey.best
    @survey_theme = @survey.themes_event
  end
end
