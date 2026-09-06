class CoursesController < ApplicationController
  # GET /api/courses
  def index
    @courses = Course.includes(:tutors).all
  end

  def show
    @course = Course.includes(:tutors).find(course_id)
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Course not found' }, status: :not_found
  end

  # POST /api/courses
  def create
    @course = Course.new(course_params)

    if @course.save
      render :create, status: :created
    else
      render json: { errors: @course.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def course_id
    params[:id]
  end

  def course_params
    params.require(:course).permit(
      :name, :duration,
      tutors_attributes: [:name, :email]
    )
  end
end
