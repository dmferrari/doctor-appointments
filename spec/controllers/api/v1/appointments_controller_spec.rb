# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::V1::AppointmentsController, type: :controller do # rubocop:disable Metrics/BlockLength
  let(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let(:date) { Time.zone.today }
  let(:appointment_date) { date }
  let(:appointment_start_time) { '11:00' }
  let(:start_time) { '10:00' }
  let(:end_time) { '17:00' }
  let(:appointment) { create(:appointment, doctor:, patient:, appointment_date:, start_time: appointment_start_time) }
  let!(:working_hours) do
    7.times do |i|
      create(:working_hour, doctor:, working_date: date + i.days, start_time:, end_time:)
    end
  end

  before { sign_in patient }

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET #show' do # rubocop:disable Metrics/BlockLength
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
      { appointment: { doctor_id: doctor&.id, appointment_date:, start_time: appointment_start_time } }
    end

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
          expect(response.body).to include("Appointment date can't be blank")
        end
      end

      context 'when the appointment date is in the past' do
        let(:appointment_date) { date - 1.day }
        let(:start_time) { '11:00' }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('errors.messages.date_cannot_be_in_past'))
        end
      end

      context 'when the appointment date is not a valid date' do
        let(:appointment_date) { 'invalid_date' }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("Appointment date can't be blank")
        end
      end

      context 'when the start time is not provided' do
        let(:appointment_start_time) { nil }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("Start time can't be blank")
        end
      end

      context 'when the start time is not a valid time' do
        let(:appointment_start_time) { '99:99' }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('errors.messages.invalid_time_format'))
        end
      end

      context 'when the appointment is not within the doctor working hours' do
        let(:appointment_start_time) { '22:00' }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('errors.messages.outside_working_hours'))
        end
      end

      context 'when the appointment is not available' do
        let(:appointment_start_time) { '12:00' }
        let!(:existing_appointment) do
          create(:appointment, doctor:, patient:, appointment_date:, start_time: appointment_start_time)
        end

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('errors.messages.appointment_slot_not_available'))
        end
      end

      context 'when the patient has an appointment at the same date' do
        let(:appointment_start_time) { '19:00' }
        let!(:existing_appointment) do
          create(:appointment, doctor:, patient:, appointment_date:, start_time: '13:00')
        end

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include(I18n.t('errors.messages.taken_for_doctor_patient_date'))
        end
      end

      context 'when the doctor does not exist' do
        let(:doctor) { nil }
        let(:working_hours) { nil }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the doctor and the patient are the same user' do
        let(:patient) { doctor }

        it 'returns an unprocessable entity error' do
          post :create, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'PATCH #update' do # rubocop:disable Metrics/BlockLength
    let(:appointment_id) { appointment.id }
    let(:updated_appointment_date) { appointment.appointment_date }
    let(:updated_start_time) { '14:00' }
    let(:appointment_params) do
      { id: appointment_id,
        appointment: { appointment_date: updated_appointment_date, start_time: updated_start_time } }
    end

    context 'when the appointment is updated successfully' do
      it 'returns a successful response' do
        patch :update, params: appointment_params
        expect(response).to have_http_status(:ok)
        expect(response.body).to eq(AppointmentSerializer.new(appointment.reload).to_json)
      end
    end

    context 'when the appointment is not updated successfully' do # rubocop:disable Metrics/BlockLength
      context 'when the appointment is not found' do
        let(:appointment_id) { -1 }

        it 'returns a not found error' do
          patch :update, params: appointment_params
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the appointment belongs to another patient' do
        before do
          appointment.update(patient: create(:user, :patient))
        end

        it 'returns a not found error' do
          patch :update, params: appointment_params
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when the appointment date is in the past' do
        let(:updated_appointment_date) { appointment.appointment_date - 1.day }

        it 'returns an unprocessable entity error' do
          patch :update, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the appointment date is not a valid date' do
        let(:updated_appointment_date) { 'invalid_date' }

        it 'returns an unprocessable entity error' do
          patch :update, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context 'when the start time is not a valid time' do
        let(:updated_start_time) { '99:99' }

        it 'returns an unprocessable entity error' do
          patch :update, params: appointment_params
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'returns a successful response' do
      expect(response).to have_http_status(:ok)
    end
  end
end
