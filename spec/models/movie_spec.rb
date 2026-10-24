require 'rails_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday to perform the TMDb request' do
      expect(Faraday).to receive(:get).and_call_original

      Movie.find_in_tmdb({ title: 'hacker', language: 'en' })
    end

    it 'returns Movie objects from TMDb results' do
      movies = Movie.find_in_tmdb({ title: 'olympics', language: 'en' })

      expect(movies.length).to eq(2)
      expect(movies.first).to be_a(Movie)
      expect(movies.first.title).to eq('Sydney 2000 Olympics Opening Ceremony')
      expect(movies.first.rating).to eq('R')
      expect(movies.first).not_to be_persisted
    end

    it 'filters movies already in the database' do
      Movie.create!(title: 'Sydney 2000 Olympics Opening Ceremony', rating: 'R', description: 'Already added', release_date: '2000-09-15')

      movies = Movie.find_in_tmdb({ title: 'olympics', language: 'en' })

      expect(movies.map(&:title)).not_to include('Sydney 2000 Olympics Opening Ceremony')
      expect(movies.map(&:title)).to include('Sydney 2000 Olympics Closing Ceremony')
    end
  end
end