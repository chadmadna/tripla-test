require 'rails_helper'

RSpec.describe 'Schedules API', type: :request do
  before do
    DatabaseCleaner.start
  end

  after do
    DatabaseCleaner.clean
  end

  let(:user) { create(:user) }
  let(:headers) { { 'Authorization' => "Bearer #{generate_jwt_token(user)}" } }

  describe 'GET /api/schedules' do
    it 'returns a list of schedules' do
      get '/api/schedules', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['data']).to be_an(Array)
    end
  end

  describe 'POST /api/schedules/clock_in' do
    it 'clocks in the user' do
      post '/api/schedules/clock_in', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['clock_in']).not_to be_nil
    end
  end

  describe 'POST /api/schedules/clock_out' do
    it 'clocks out the user' do
      post '/api/schedules/clock_out', headers: headers
      expect(response).to have_http_status(:ok)
      expect(json['clock_out']).not_to be_nil
    end
  end
end
