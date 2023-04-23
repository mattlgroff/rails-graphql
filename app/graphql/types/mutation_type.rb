module Types
  class MutationType < Types::BaseObject
    # Add a field to the MutationType that adds a new comment
    field :add_comment, Types::CommentType, null: false do
      argument :comment, String, required: true
      argument :person_id, ID, required: true
    end

    def add_comment(comment:, person_id:)
      Comment.create!(
        comment: comment,
        person_id: person_id
      )
    end

    # Add a field to the MutationType that adds a new person
    field :add_person, Types::PersonType, null: false do
      argument :first_name, String, required: true
      argument :last_name, String, required: true
      argument :email, String, required: true
      argument :job_title, String, required: true
      argument :avatar, String, required: true
    end

    def add_person(first_name:, last_name:, email:, job_title:, avatar:)
      Person.create!(
        first_name: first_name,
        last_name: last_name,
        email: email,
        job_title: job_title,
        avatar: avatar
      )
    end
  end
end
