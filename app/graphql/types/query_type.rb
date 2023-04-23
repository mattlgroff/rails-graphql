module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :comments, 
    [Types::CommentType],
    null: false, 
    description: "Return a list of comments"

    def comments
      Comment.all
    end 

    # Ask for a person by ID
    field :person,
    Types::PersonType,
    null: true,
    description: "Find a person by ID" do
      argument :id, ID, required: true
    end
    
    def person(id:)
      Person.find(id)
    end

    # Ask for a list of people
    field :people,
    [Types::PersonType],
    null: false,
    description: "Return a list of people"

    def people
      Person.all
    end
  end
end
