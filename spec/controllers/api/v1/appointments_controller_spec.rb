# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::V1::AppointmentsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let(:date) { Time.zone.today }
  let(:appointment_date) { date }
  let(:start_time) { '10:00' }
  let(:end_time) { '17:00' }
  let!(:appointment) do
    create(:appointment, doctor:, patient:, appointment_date: date, start_time:)
  end
  let!(:working_hours) do
    7.times do |i|
      create(:working_hour, doctor:, working_date: date + i.days, start_time:, end_time:)
    end
  end

  describe 'GET #index' do
    before { sign_in patient }

    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
      get :index
    end
  end

  describe 'GET #show' do # rubocop:disable Metrics/BlockLength
    before { sign_in patient }

    context 'when the appointment exists' do
      context 'when the appointment belongs to the patient' do
        it 'returns the appointment' do
          get :show, params: { id: appointment.id }
          expect(response).to have_http_status(:ok)
          expect(response.body).to eq(AppointmentSerializer.new(appointment).to_json)
        end
      end

      context 'when the appointment does not belong to the patient' do
        let!(:another_appointment) do
          create(:appointment, doctor:, patient: create(:user, :patient), appointment_date: date, start_time: '16:00')
        end

        it 'returns a not found error' do
          get :show, params: { id: another_appointment.id }
          expect(response).to have_http_status(:not_found)
          expect(response.body).to eq({ error: I18n.t('errors.messages.not_found',
                                                      resource: I18n.t('appointment')) }.to_json)
        end
      end
    end

    context 'when the appointment does not exist' do
      it 'returns a not found error' do
        get :show, params: { id: -1 }
        expect(response).to have_http_status(:not_found)
        expect(response.body).to eq({ error: I18n.t('errors.messages.not_found',
                                                    resource: I18n.t('appointment')) }.to_json)
      end
    end
  end

  describe 'POST #create' do # rubocop:disable Metrics/BlockLength
    let(:appointment_params) do
      { appointment: { doctor_id: doctor&.id, appointment_date:, start_time: } }
    end

    before { sign_in patient }

    context 'when the appointment is created successfully' do
      let(:appointment_date) { date + 1.day }
      let(:start_time) { '11:00' }

      it 'returns a successful response' do
        post :create, params: appointment_params
        expect(response).to have_http_status(:created)
        expect(response.body).to eq(AppointmentSerializer.new(Appointment.last).to_json)
      end
    end

    context 'when the appointment is not created successfully' do # rubocop:disable Metrics/BlockLength
      context 'when the appointment date is not provided' do
        let(:appointment_date) { nil }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the start time is not provided' do
        let(:start_time) { nil }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the doctor does not exist' do
        let(:doctor) { nil }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the appointment date is in the past' do
        let(:appointment_date) { date - 1.day }
        let(:start_time) { '11:00' }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
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
