# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::V1::AppointmentsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let(:doctor_and_patient) { create(:user, :doctor_and_patient) }
  let(:user) { create(:user) }
  let(:appointment) do
    create(:appointment, doctor:, patient:, appointment_date: Time.zone.today, start_time: '10:00')
  end

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
      get :index
    end
  end

  describe 'GET #show' do
    context 'when the appointment exists' do
      context 'when the appointment belongs to the patient' do
        it 'returns the appointment' do
          expect(response).to have_http_status(:ok)
        end
      end
    end
  end

  describe 'POST #create' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:created)
    end
  end

  describe 'PATCH #update' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'DELETE #destroy' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end
  end
end
