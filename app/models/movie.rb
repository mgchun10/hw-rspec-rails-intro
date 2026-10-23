require 'uri'
require 'json'

class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_params)
    url = 'https://api.themoviedb.org/3/search/movie'

    query = {api_key: ENV['TMDB_API_KEY'], query: search_params[:title]}

    if search_params[:release_year].present?
      query[:year] = search_params[:release_year]
    end

    if search_params[:language] == 'en'
      query[:language] = 'en-US'
    end

    full_url = "#{url}?#{URI.encode_www_form(query)}"

    response = Faraday.get(full_url)
    parsed_response = JSON.parse(response.body)

    parsed_response['results'].map do |movie|
      Movie.new(title: movie['title'], rating: 'R', description: movie['overview'], release_date: movie['release_date'])
    end
  end
end
