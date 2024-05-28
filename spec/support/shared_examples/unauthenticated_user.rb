# frozen_string_literal: true

RSpec.shared_examples 'an unauthenticated user' do
  it 'returns an unauthorized response' do
    expect(response).to have_http_status(:unauthorized)
  end
end
