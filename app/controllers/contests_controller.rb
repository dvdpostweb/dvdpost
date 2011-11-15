class ContestsController < ApplicationController

  before_filter :contests_available

  def index
    if params[:type] == 'old'
      @contests_old = ContestName.by_language(I18n.locale).by_old_date.new.ordered.all
    else
      @contest = ContestName.by_language(I18n.locale).by_date.new.ordered.first
      if @contest
        redirect_to contest_path(:id => @contest.to_param)
      end
    end
  end

  def show
    begin
      @contest = ContestName.by_language(I18n.locale).by_date.new.find(params[:id])
     rescue ActiveRecord::RecordNotFound
       @contest = nil
     end
    if @contest
      @already_played = current_customer.contests.find_by_contest_name_id(@contest.to_param)
    else
      @already_played = nil
    end
    @menu = 'contest'
  end

  def create
    @already_played = current_customer.contests.find_by_contest_name_id(params[:contest_id])
    @contest = ContestName.find_by_contest_name_id(params[:contest_id])
    if @already_played.nil?
      contest = Contest.new(params[:contests].merge(:contest_name_id => @contest.to_param))
      contest.customers_id = current_customer.to_param
      contest.language_id = DVDPost.product_languages[I18n.locale]
      contest.email = current_customer.email
      contest.pseudo = current_customer.customer_attribute.nickname
      contest.marketing_ok = 'YES'
      contest.unsubscribe = true
      contest.date = Time.now.to_s(:db)
      if contest.save
        @contest = ContestName.find_by_contest_name_id(params[:contest_id])
      else
        render :action => :new
      end
    else
      @contest = ContestName.find_by_contest_name_id(params[:contest_id])
    end
  end

  def contests_available
    @contests_available = ContestName.by_language(I18n.locale).by_date.new.ordered.all
  end
end
