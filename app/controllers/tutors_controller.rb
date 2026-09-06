class TutorsController < ApplicationController
  # POST /api/courses/:course_id/tutors
  def create
    @course = Course.find(params[:course_id])
    @tutor = @course.tutors.new(tutor_params)

    if @tutor.save
      render :create, status: :created
    else
      render json: { errors: @tutor.errors.full_messages }, status: :unprocessable_content
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Course not found' }, status: :not_found
  end

  private

  def tutor_params
    params.require(:tutor).permit(:name, :email)
  end
end
