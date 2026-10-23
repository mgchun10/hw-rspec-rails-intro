require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before :each do
      @fake_results = [double('movie1'), double('movie2')]
    end

    it 'renders the search page without performing a search on initial visit' do
      expect(Movie).not_to receive(:find_in_tmdb)

      get :search_tmdb

      expect(response).to render_template('search_tmdb')
      expect(assigns(:movies)).to eq([])
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).
        with('hardware').
        and_return(@fake_results)

      get :search_tmdb, params: { search_terms: 'hardware' }
    end

    it 'shows an error when title is missing' do
      get :search_tmdb, params: {
        title: '',
        release_year: '2000',
        language: 'en'
      }

      expect(flash[:warning]).to eq('Please fill in all required fields!')
    end

    it 'shows an error when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])

      get :search_tmdb, params: {
        title: 'nonexistent movie',
        release_year: '',
        language: 'en'
      }

      expect(flash[:warning]).to eq('No movies found with given parameters!')
    end

    describe 'after valid search' do
      before :each do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: { search_terms: 'hardware' }
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end
  end

  describe 'adding a movie from TMDb' do
    let(:movie_params) do
      {
        title: 'Manhunter',
        rating: 'R',
        description: 'A movie description',
        release_date: '1986-08-15'
      }
    end

    it 'creates the selected movie in the database' do
      expect {
        post :add_movie, params: { movie: movie_params }
      }.to change(Movie, :count).by(1)
    end

    it 'redirects to search page with success message' do
      post :add_movie, params: { movie: movie_params }

      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:notice]).to eq(
        'Manhunter was successfully added to RottenPotatoes.'
      )
    end
  end
end