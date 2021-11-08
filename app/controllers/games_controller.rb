require 'securerandom'
require 'json'
require 'open-uri'

class GamesController < ApplicationController
  def new
    @letters = generate_grid
  end

  def score
    @answer = generate_answer
  end

  private

  def generate_grid
    add = SecureRandom.alphanumeric(10)
    add = SecureRandom.alphanumeric(10) until add.match(/[a-zA-Z]{10}/)
    vocals = %w[A E]
    grid = [vocals, add].join.upcase
    grid.upcase.chars.shuffle
  end

  def generate_answer
    if !grid_check
      answer = "Sorry '#{params[:guess].capitalize}' cannot be build out of the given grid"
    elsif !english_word
      answer = "Sorry '#{params[:guess].capitalize}' is not part of the English dictionary"
    else
      answer = "Congrats! '#{params[:guess].capitalize}' has a score of: #{compute_score}"
    end
    answer
  end

  def grid_check
    grid = params[:letters]
    attempt = params[:guess].upcase
    attempt.upcase.chars.all? do |letter|
      grid.count(letter) >= attempt.upcase.chars.count(letter)
    end
  end

  def english_word
    attempt = params[:guess].downcase
    response = URI.open("https://wagon-dictionary.herokuapp.com/#{attempt}")
    json = JSON.parse(response.read)
    json['found']
  end

  def compute_score
    params[:guess].length.to_i * 2.5
  end
end
