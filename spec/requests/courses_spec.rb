require 'rails_helper'

RSpec.describe 'Courses API', type: :request do
  describe 'POST /api/courses' do
    let(:valid_params) do
      {
        course: {
          name: 'Ruby on Rails',
          duration: '3 months',
          tutors_attributes: [
            { name: 'Alice', email: 'alice@example.com' },
            { name: 'Bob', email: 'bob@example.com' }
          ]
        }
      }
    end

    context 'with valid params' do
      it 'creates a course with tutors' do
        expect {
          post '/api/courses', params: valid_params, as: :json
        }.to change(Course, :count).by(1).and change(Tutor, :count).by(2)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['name']).to eq('Ruby on Rails')
        expect(json['tutors'].size).to eq(2)
      end
    end

    context 'with invalid params' do
      it 'returns errors when name is missing' do
        invalid_params = { course: { duration: '3 months', tutors_attributes: [{ name: 'A', email: 'a@x.com' }] } }
        post '/api/courses', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Name can't be blank")
      end

      it 'returns errors when duration is missing' do
        invalid_params = { course: { name: 'No Duration Course', tutors_attributes: [{ name: 'A', email: 'a@x.com' }] } }
        post '/api/courses', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include("Duration can't be blank")
      end

      it 'returns errors when duration format is invalid' do
        invalid_params = {
          course: {
            name: 'Bad Duration Course',
            duration: 'three months',
            tutors_attributes: [{ name: 'A', email: 'a@x.com' }]
          }
        }
        post '/api/courses', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include(
          "Duration must be a number followed by day(s)/week(s)/month(s)/year(s), e.g. '3 months'"
        )
      end

      it 'returns errors when tutor email is duplicated' do
        create(:tutor, email: 'dup@example.com')
        params = {
          course: {
            name: 'Duplicate Test',
            duration: '1 month',
            tutors_attributes: [{ name: 'X', email: 'dup@example.com' }]
          }
        }
        post '/api/courses', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns errors when course name already exists' do
        create(:course, name: 'Existing Course')
        params = {
          course: {
            name: 'Existing Course',
            duration: '2 months',
            tutors_attributes: [{ name: 'A', email: 'a@x.com' }]
          }
        }
        post '/api/courses', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Name has already been taken')
      end

      it 'does not create a course when tutor data is invalid' do
        params = {
          course: {
            name: 'Bad Tutor Course',
            duration: '2 months',
            tutors_attributes: [{ name: '', email: 'invalid-email' }]
          }
        }
        expect {
          post '/api/courses', params: params, as: :json
        }.not_to change(Course, :count)

        expect(response).to have_http_status(:unprocessable_content)
      end

      it 'returns errors when two tutors in the same request share the same name' do
        params = {
          course: {
            name: 'Name Clash Course',
            duration: '2 months',
            tutors_attributes: [
              { name: 'Same Name', email: 'first@x.com' },
              { name: 'Same Name', email: 'second@x.com' }
            ]
          }
        }
        post '/api/courses', params: params, as: :json
        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Tutors in the same course must have unique names')
      end
    end

    context 'custom validation: must_have_at_least_one_tutor via API' do
      it 'returns 422 when creating a course without any tutors' do
        params = { course: { name: 'Solo Course', duration: '1 month' } }
        post '/api/courses', params: params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json['errors']).to include('Course must have at least one tutor')
      end

      it 'succeeds when creating a course with at least one tutor' do
        params = {
          course: {
            name: 'Accompanied Course',
            duration: '1 month',
            tutors_attributes: [{ name: 'Solo Tutor', email: 'solo@example.com' }]
          }
        }
        post '/api/courses', params: params, as: :json

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['tutors'].size).to eq(1)
      end
    end
  end

  describe 'GET /api/courses' do
    context 'when courses exist' do
      before do
        create(:course, name: 'Course A', tutors_count: 2)
        create(:course, name: 'Course B', tutors_count: 1)
      end

      it 'returns all courses with their tutors' do
        get '/api/courses', as: :json

        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)

        expect(json.size).to eq(2)
        course_a = json.find { |c| c['name'] == 'Course A' }
        expect(course_a['tutors']).to be_an(Array)
        expect(course_a['tutors'].size).to eq(2)
        expect(course_a).to include('id', 'name', 'duration', 'tutors')
      end

      it 'includes correct tutor attributes' do
        get '/api/courses', as: :json
        json = JSON.parse(response.body)
        tutor = json.first['tutors'].first
        expect(tutor).to include('id', 'name', 'email')
      end
    end

    context 'when no courses exist' do
      it 'returns an empty array' do
        get '/api/courses', as: :json
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end
    end
  end
end