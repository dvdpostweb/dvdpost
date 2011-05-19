class ActorsController < ApplicationController
  def index
    @actors = Hash.new()
    ('a'..'z').each do |l|
      @actors[l] = Actor.by_kind(:adult).with_image.by_letter(l)
    end
  end
end