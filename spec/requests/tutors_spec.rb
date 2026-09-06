require 'rails_helper'

RSpec.describe 'Tutors API', type: :request do
  describe 'POST /api/courses/:course_id/tutors' do
    let!(:course) { create(:course, tutors_count: 1) }

    context 'with valid params' do
      it 'adds a new tutor to the existing course' do
        params = { tutor: { name: 'Mayur', email: 'mayur@example.com' } }

        expect {
          post "/api/courses/#{course.id}/tutors", params: params, as: :json
        }.to change(Tutor, :count).by(1)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Mayur')
        expect(json['email']).to eq('mayur@example.com')
        expect(json['course_id']).to eq(course.id)
      end

      it 'allows the same tutor name to be reused across different courses' do
        other_course = create(:course, tutors_count: 1)
        create(:tutor, name: 'Rushi', course: other_course)

        params = { tutor: { name: 'Rushi', email: 'rushi.new@example.com' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:created)
      end
    end

    context 'with invalid params' do
      it 'returns an error when name is missing' do
        params = { tutor: { email: 'noname@example.com' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
      end

      it 'returns an error when email is missing' do
        params = { tutor: { name: 'No Email' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Email can't be blank")
      end

      it 'returns an error when email format is invalid' do
        params = { tutor: { name: 'Bad Email', email: 'not-an-email' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns an error when the tutor name already exists in the same course' do
        existing_tutor = course.tutors.first
        params = { tutor: { name: existing_tutor.name, email: 'different@example.com' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Name already teaches this course')
      end

      it 'returns an error when the email already exists globally (tutor teaches only one course)' do
        create(:tutor, email: 'taken@example.com')
        params = { tutor: { name: 'New Name', email: 'taken@example.com' } }
        post "/api/courses/#{course.id}/tutors", params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Email has already been taken')
      end

      it 'does not create a tutor when validation fails' do
        params = { tutor: { name: '', email: 'invalid' } }
        expect {
          post "/api/courses/#{course.id}/tutors", params: params, as: :json
        }.not_to change(Tutor, :count)
      end
    end

    context 'when course does not exist' do
      it 'returns 404 not found' do
        params = { tutor: { name: 'Ghost', email: 'ghost@example.com' } }
        post '/api/courses/999999/tutors', params: params, as: :json

        expect(response).to have_http_status(:not_found)
        json = JSON.parse(response.body)
        expect(json['error']).to eq('Course not found')
      end
    end
  end
end