class TranslationsController < ApplicationController
  layout 'translator'
  before_filter :http_authenticate

  before_filter :find_locale
  protect_from_forgery :only => []

  def find_locale
    @locale = Locale.find(params[:locale_id])
    @main_locale = @locale.main? ? @locale : Locale.find_main_cached
  end
  
  def index    
    @groups = @main_locale.translations.find(:all, :order => 'namespace, id').group_by(&:namespace)
  end

  def new
    @translation = Translation.new
  end

  def edit
    @translation = Translation.find(params[:id])
  end

  def create
    translation_params = params[:translation]
    if params[:original_id]
      original_translation = Translation.find(params[:original_id])
      translation_params[:tr_key] = original_translation.tr_key
      translation_params[:namespace] = original_translation.namespace
    end
    @translation = @locale.translations.new(translation_params)
    if @translation.save
      localized_translation = @translation.counterpart_in(@locale)
      render :text => locale_translation_path(:locale_id => @locale.to_param, :id => localized_translation.to_param)
    else
      render :action => :new
    end
  end

  def update
    @translation = Translation.find(params[:id])
    #params[:translation][:text] = CGI::unescapeHTML(params[:translation][:text])
    if @translation.update_attributes(params[:translation])
      localized_translation = @translation.counterpart_in(@locale)
      render :text => locale_translation_path(:locale_id => @locale.to_param, :id => localized_translation.to_param)
    else
      render :action => :edit
    end
  end

  def destroy
    @translation = Translation.find(params[:id])
    @translation.destroy
    redirect_to translations_path
  end
end
