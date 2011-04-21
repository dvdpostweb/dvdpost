class CustomerSurveysController < ApplicationController
  def new
    @survey = Survey.find(params[:survey_id])
    @details = @survey.survey_details
  end

  def create
    survey = Survey.find(params[:survey_id])
    if survey.customer_surveys.find_by_customer_id(current_customer.to_param)
      redirect_to survey_path(:id =>  params[:survey_id])
    else
      #customer_survey = CustomerSurvey.new(params[:customer_survey].merge(:customer_id => current_customer.to_param, :survey_id => survey.to_param))
      #customer_survey.save
    
      #survey.update_attribute(:total_rating, (survey.total_rating + 1))
    
      details = survey.survey_details.find(params[:customer_survey][:response])
      logger.debug("@@@#{details.inspect}")
      total = (details.rating + 1)
      details.update_attribute(:rating, total)
      redirect_to survey_path(:id => params[:survey_id])
    end 
  end
end
