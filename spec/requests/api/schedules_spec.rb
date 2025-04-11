require 'rails_helper'

require 'rake'
load File.expand_path("../../../../lib/tasks/seed_test_data.rake", __FILE__)
Rake::Task.define_task(:environment)

RSpec.describe 'Schedules API', type: :request do
  before :all do
    Rake::Task['db:seed_test_data'].execute
    @user = create(:user)
  end

  after :all do
    DatabaseCleaner.clean
  end

  let(:user) { @user }

  before do
    post '/login', params: { user: { email: @user.email, password: @user.password } }
    @headers = { 'Authorization' => "Bearer #{JSON.parse(response.body)['data']['user']['token']}" }
  end

  describe 'GET /api/sleep_schedules' do
    before do
      patch '/api/users/2/follow', headers: @headers
    end

    it 'returns a list of schedules' do
      get '/api/sleep_schedules', headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to be_an(Array)
    end
  end

  describe 'POST /api/clock_in' do
    it 'clocks in the user' do
      post '/api/clock_in', headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['clock_in']).not_to be_nil
    end
  end

  describe 'POST /api/clock_out' do
    before do
      post '/api/clock_in', headers: @headers
    end

    it 'clocks out the user' do
      post '/api/clock_out', headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['clock_out']).not_to be_nil
    end
  end
end
