class GamesController < ApplicationController

require 'open-uri'
require 'json'

  def game
    @grid = Array.new(8) { ('A'..'Z').to_a[rand(26)] }
  end

  def score
    start_time = Time.now
    @grid = params[:grid]
    @attempt = params[:attempt]

    end_time = Time.now

    @time_taken = end_time - start_time
    # (attempt, grid, start_time, end_time)
    if included?(@attempt.upcase.split(""), @grid)
      if get_translation(@attempt)
        @score = score_and_message(@attempt, @grid, @time_taken)
      else
        @score = "this is not a word, asshole !"
      end
    else
      @score = "not included in the grid"
    end

    # result = { time: end_time - start_time }

    # result[:translation] = get_translation(@attempt)
    # result[:score], result[:message] = score_and_message(
    # attempt, result[:translation], grid, result[:time])

    # @translation = result[:translation]


  end

  def score_and_message(attempt, grid, time)
    score = compute_score(attempt, time)
    [score, "well done"]
  end

  def compute_score(attempt, time_taken)
    (time_taken > 60.0) ? 0 : attempt.size * (1.0 - time_taken / 60.0)
  end




  def included?(guess, grid)
    guess.all? { |letter| guess.count(letter) <= grid.count(letter) }
  end

  def get_translation(word)
  api_key = "1c912ecf-5ce4-4db2-85b2-05f79275a266"
  begin
    response = open("https://api-platform.systran.net/translation/text/translate?source=en&target=fr&key=#{api_key}&input=#{word}")
    json = JSON.parse(response.read.to_s)
    if json['outputs'] && json['outputs'][0] && json['outputs'][0]['output'] && json['outputs'][0]['output'] != word
      return json['outputs'][0]['output']
    end
  rescue
    if File.read('/usr/share/dict/words').upcase.split("\n").include? word.upcase
      return word
    else
      return nil
    end
  end
end

end
