json.array! @courses do |course|
  json.id course.id
  json.name course.name
  json.duration course.duration
  json.tutors course.tutors do |tutor|
    json.id tutor.id
    json.name tutor.name
    json.email tutor.email
  end
end
