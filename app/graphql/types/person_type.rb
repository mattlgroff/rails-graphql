# frozen_string_literal: true

module Types
  class PersonType < Types::BaseObject
    field :id, ID, null: false
    field :first_name, String
    field :last_name, String
    field :email, String
    field :job_title, String
    field :avatar, String
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

    # Add a field to the PersonType that returns a full name
    field :full_name, String, null: false
    def full_name 
      [object.first_name, object.last_name].compact.join(" ")
    end 

    # Add a field to the PersonType that returns a list of comments
    field :comments, [Types::CommentType], null: false
    def comments
      object.comments
    end
  end
end
