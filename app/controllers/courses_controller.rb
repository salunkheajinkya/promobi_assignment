class CoursesController < ApplicationController
  # GET /api/courses
  def index
    @courses = Course.includes(:tutors).all
  end

  # POST /api/courses
  def create
    @course = Course.new(course_params)

    if @course.save
      render :create, status: :created
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def course_params
    params.require(:course).permit(
      :name, :duration,
      tutors_attributes: [:name, :email]
    )
  end
end
