require 'rails_helper'

RSpec.describe 'User API', type: :request do
  before :all do
    DatabaseCleaner.start
    create(:publisher)
    create(:role, :regular)
    create(:role, :admin)
    @admin = create(:user, :admin, email: 'admin@example.com')
    @user = create(:user)
    @regular_user = create(:user)
  end

  after :all do
    DatabaseCleaner.clean
  end

  let(:user) { @user }
  let(:regular_user) { @regular_user }

  before do
    post '/login', params: { user: { email: @user.email, password: @user.password } }
    @headers = { 'Authorization' => "Bearer #{JSON.parse(response.body)['data']['user']['token']}" }
  end

  describe 'GET users#index' do
    it 'returns a list of users' do
      get '/api/users', headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']).to be_an(Array)
    end
  end

  describe 'GET users#show' do
    it 'returns a user' do
      get "/api/users/#{regular_user.id}", headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['data']['email']).to eq(regular_user.email)
    end
  end

  describe 'PATCH users#follow' do
    it 'follows a user' do
      patch "/api/users/#{regular_user.id}/follow", headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq("User '#{regular_user.name}' followed")
    end
  end

  describe 'PATCH users#unfollow' do
    before do
      patch "/api/users/#{regular_user.id}/follow", headers: @headers
    end
    it 'unfollows a user' do
      patch "/api/users/#{regular_user.id}/unfollow", headers: @headers
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)['message']).to eq("User '#{regular_user.name}' unfollowed")
    end
  end
end
