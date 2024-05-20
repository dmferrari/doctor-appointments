# frozen_string_literal: true

require 'rails_helper'
require 'spec_helper'

RSpec.describe Api::V1::DoctorsController, type: :controller do # rubocop:disable Metrics/BlockLength
  include DateTimeParser

  let!(:doctor) { create(:user, :doctor) }
  let(:patient) { create(:user, :patient) }
  let!(:date) { Time.zone.today }
  let(:invalid_date) { 'invalid_date' }
  let(:start_time) { '10:00' }
  let(:end_time) { '17:00' }

  let(:availability) do
    [
      { date:, start_time: '10:00', end_time: '11:00' },
      { date:, start_time: '14:00', end_time: '14:45' },
      { date: date + 1.day, start_time: '15:00', end_time: '16:00' },
      { date: date + 2.days, start_time: '17:00', end_time: '18:00' }
    ]
  end

  before do
    sign_in patient
    (0..7).each do |i|
      create(:working_hour, doctor:, working_date: date + i.days, start_time:, end_time:)
    end
  end

  describe 'GET #working_hours' do # rubocop:disable Metrics/BlockLength
    context 'when the doctor exists' do
      context 'when the date is provided' do
        it 'returns the working hours' do
          get :working_hours, params: { id: doctor.id, date: }

          serialized_working_hours =
            ActiveModelSerializers::SerializableResource.new(
              doctor.working_hours(date:), each_serializer: WorkingHourSerializer
            ).to_json
          expect(response.body).to eq(serialized_working_hours)
          expect(response.parsed_body.size).to eq(1)
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the date is not provided' do
        it 'returns the working hours for the next 7 days' do
          get :working_hours, params: { id: doctor.id }

          serialized_working_hours =
            ActiveModelSerializers::SerializableResource.new(
              doctor.working_hours, each_serializer: WorkingHourSerializer
            ).to_json
          expect(response.body).to eq(serialized_working_hours)
          expect(response.parsed_body.size).to eq(7)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when the doctor does not exist' do
      it 'returns not found' do
        get :working_hours, params: { id: -1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET #availability' do # rubocop:disable Metrics/BlockLength
    context 'when the doctor exists' do # rubocop:disable Metrics/BlockLength
      context 'when the date is provided' do
        it 'returns the availability for that day' do
          get :availability, params: { id: doctor.id, date: }

          serializable_availability = SerializableAvailability.wrap(doctor.availability(date:))
          serialized_availability =
            ActiveModelSerializers::SerializableResource.new(
              serializable_availability, each_serializer: AvailabilitySerializer
            ).to_json

          expect(response.body).to eq(serialized_availability)
          expect(response.parsed_body.size).to eq(1)
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when the date is not provided' do
        it 'returns the availability for the next 7 days' do
          get :availability, params: { id: doctor.id }

          serializable_availability = SerializableAvailability.wrap(doctor.availability)
          serialized_availability =
            ActiveModelSerializers::SerializableResource.new(
              serializable_availability, each_serializer: AvailabilitySerializer
            ).to_json

          expect(response.body).to eq(serialized_availability)
          expect(response.parsed_body.size).to eq(7)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when the doctor does not exist' do
      it 'returns not found' do
        get :availability, params: { id: -1 }
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
