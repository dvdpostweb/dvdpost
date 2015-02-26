class GeneralesController < ApplicationController
    before_filter :http_authenticate
  def edit
    render :layout => false
  end

  def update
    #dvdpost
    sql = "UPDATE `generalglobalcode` SET `CodeValue` = '#{params[:start]}' WHERE `CodeType` = 'OFFLINE_CUST_START'"
    results = ActiveRecord::Base.connection.execute(sql)
    sql = "UPDATE `generalglobalcode` SET `CodeValue` = '#{params[:end]}' WHERE `CodeType` = 'OFFLINE_CUST_END'"
    results = ActiveRecord::Base.connection.execute(sql)
    #plush
    sql = "UPDATE plush_#{Rails.env == 'production' ? 'production' : 'staging'}.generalglobalcode SET `CodeValue` = '#{params[:start]}' WHERE `CodeType` = 'OFFLINE_CUST_START'"
    results = ActiveRecord::Base.connection.execute(sql)
    sql = "UPDATE plush_#{Rails.env == 'production' ? 'production' : 'staging'}.generalglobalcode SET `CodeValue` = '#{params[:end]}' WHERE `CodeType` = 'OFFLINE_CUST_END'"
    results = ActiveRecord::Base.connection.execute(sql)
    
    redirect_to :action => :edit

  end
end