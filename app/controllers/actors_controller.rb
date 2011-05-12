class ActorsController < ApplicationController
  def index
    letter ="a"
    @actors_html = Actor.by_kind(:adult).by_letter(letter)
    
  end
end