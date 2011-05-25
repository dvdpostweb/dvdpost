class CollectionsController < ApplicationController
  def index
    @collections = Collection.by_kind(params[:kind])
  end
end