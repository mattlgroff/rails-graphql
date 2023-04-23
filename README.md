# How to make a GraphQL API with Rails

I followed (this guide)[https://www.apollographql.com/blog/community/backend/using-graphql-with-ruby-on-rails/] from Apollo to make this GraphQL API. I've added some notes to help me remember how to do this in the future, and following the Person with Comments models instead of the Artist with Items.


## Generate the application with rails new
```bash
rails new rails-graphql -d postgresql --skip-action-mailbox --skip-action-text --skip-spring --webpack=react -T
```

This command will create a new rails application with the following options:
  - `rails new rails-graphql` This command creates a new Rails application with the name rails-graphql.

  - `-d postgresql` Use postgresql as database

  - `--skip-action-mailbox` Skip action-mailbox gem

  - `--skip-action-text` Skip action-text gem

  - `--skip-spring`  Skip spring gem

  - `--webpack=react`: This flag tells Rails to use Webpack for managing the application's JavaScript assets and to configure it for React. Webpack is a powerful bundler for JavaScript applications, and React is a popular JavaScript library for building user interfaces. By specifying --webpack=react, the Rails application will be pre-configured to work with React.

  - `-T`: This flag tells Rails not to include the default test suite (Minitest). This is useful if you plan to use a different testing framework, such as RSpec, for your application.


`action-mailbox` - Action Mailbox routes incoming emails to controller-like mailboxes for processing in Rails. It ships with ingresses for Mailgun, Mandrill, Postmark, and SendGrid. You can also handle inbound mails directly via the built-in Exim, Postfix, and Qmail ingresses.

`action-text` - Action Text brings rich text content and editing to Rails. It includes the Trix editor that handles everything from formatting to links to quotes to lists to embedded images and galleries.

`spring` - Spring speeds up development by keeping your application running in the background so you don't need to boot it every time you run a test, rake task or migration.

## Our changes to get graphql working

### UUID for primary keys
Not required, but I prefer using a UUID for my primary keys. Edit your `config/application.rb` file and add the following line to the `Application` class:

```ruby
    # Default to UUIDs for primary keys
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
```

Next, since we're using postgres, we need to add a migration for postgres to generate uuids. Create a new migration file with the following command:

```bash
rails generate migration enable_pgcrypto_extension
```

Edit the migration file and add the following line to the `change` method:

```ruby
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
```

This will only enable the extension if it's not already enabled. The migration should look something like this:

```ruby
class EnablePgcryptoExtension < ActiveRecord::Migration[7.0]
  def change
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  end
end
```

### Creating models

Here are the typeDefs we're going to use for our models:

```graphql
"A person"
  type Person {
    id: ID!
    first_name: String!
    last_name: String!
    email: String!
    job_title: String!
    avatar: String
    comments: [Comment!]!
  }
  
  "A comment"
  type Comment {
    id: ID!
    comment: String!
  }
`;
```

Now we can create our first model. We'll create a `Person` model with the following command:

```bash 
rails g model Person first_name:string last_name:string email:string job_title:string avatar:string
```

This will create a `Person` model with the following attributes:
  - `first_name`: string
  - `last_name`: string
  - `email`: string
  - `job_title`: string
  - `avatar`: string

Active Record will generate a model and a migration file for us. The migration file will look something like this:

```ruby
class CreatePeople < ActiveRecord::Migration[7.0]
  def change
    create_table :people, id: :uuid do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :job_title
      t.string :avatar

      t.timestamps
    end
  end
end
```

Next we'll make the `Comment` model.

```bash
rails g model Comment person:references comment:string
```

This will create a `Comment` model with the following attributes:
  - `comment`: string
  - `person`: references // This will create a foreign key to the `Person` model

The migration file will look something like this:
```ruby
class CreateComments < ActiveRecord::Migration[7.0]
  def change
    create_table :comments, id: :uuid do |t|
      t.references :person, null: false, foreign_key: true, type: :uuid
      t.string :comment

      t.timestamps
    end
  end
end
```

### Postgres is needed

Make sure you have Postgres running before running the migration. 

Running Postgres with Docker
```bash
docker run -d --name my-postgres -p 5432:5432 -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_DB=rails_graphql_development postgres

```

You can configure your development database in the `config/database.yml` file.
```yaml
development:
  <<: *default
  database: rails_graphql_development
  username: postgres
  password: mysecretpassword
  host: localhost
```

### Migrate the database
Now you can run `rails db:migrate` to create the tables in your database.
```bash
rails db:migrate
```

If successful, you should see something like this:
```bash
== 20230423020452 EnablePgcryptoExtension: migrating ==========================
-- extension_enabled?("pgcrypto")
   -> 0.0111s
-- enable_extension("pgcrypto")
   -> 0.0082s
== 20230423020452 EnablePgcryptoExtension: migrated (0.0194s) =================

== 20230423020459 CreatePeople: migrating =====================================
-- create_table(:people, {:id=>:uuid})
   -> 0.0125s
== 20230423020459 CreatePeople: migrated (0.0126s) ============================

== 20230423020504 CreateComments: migrating ===================================
-- create_table(:comments, {:id=>:uuid})
   -> 0.0116s
== 20230423020504 CreateComments: migrated (0.0116s) ==========================
```

### Add the relationship between the models
To add the relationship between the `Person` and their `Comments`, navigate to the app/models/person.rb file and add has_many :comments, dependent: :destroy

### Seeding the database
We will need some pre-generated data to work with and render to our page. In the db/seeds/rb file add the following contents and save the file. 

```ruby
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

matt = Person.create!(
  first_name: "Matt",
  last_name: "Groff",
  email: "matt@umbrage.com",
  job_title: "Director of Engineering",
  avatar: "https://www.gravatar.com/avatar/b21bbd4c0b7f75a0fbb469c238639eb7"
)

Comment.create!(
  [
    {
      person: matt,
      comment: "This is a comment from Matt Groff",
    },
    {
      person: matt,
      comment: "This is another comment from Matt Groff",
    }
  ]
)
```

Now you can run `rails db:seed` to seed the database with the data we just created.

```bash
rails db:seed
```

### Adding GraphQL to a Ruby on Rails Project
To create our Rails-GraphQL API, let’s use a ruby gem called graphql-ruby. It will add many files to our project. It will add a lot of files that will help run our project. To add the gem, run the following line in your console followed by the generator. 

```bash
bundle add graphql

rails generate graphql:install

bundle install
```

Note: If you want GraphiQL in Production, go into your Gemfile and change the line for the graphiql-rails gem from this:

```ruby
gem "graphiql-rails", group: :development
```

to this:

```ruby
gem "graphiql-rails"
```

A Rails generator is used for automating the process of creating files with boilerplate code. It creates and updates files based on templates, etc. 

Let’s poke around in the files and see what we got! Check out the schema file, `rails_graphql_schema.rb`. This is where it declares where all the queries should go and set up mutations. 

```ruby
class RailsGraphqlSchema < GraphQL::Schema
    mutation(Types::MutationType)
    query(Types::QueryType)
end 
```

Let’s get this app running. Look at the config/routes.rb file. The generator is very helpful here! It is mounting graphiql::Rails::Engine for us. This allows us to test queries and mutation using the handy web interface, GraphiQL. Think of it as building out documentation and a fun place to test out your queries on the web. 

```ruby
Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
```

This is giving us a GraphiQL interface on get requests but only in development. We can change this to be available in production if we want. Which in this case, I do want this.

```ruby
Rails.application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  post "/graphql", to: "graphql#execute"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
end
```

Alternatively, you can use the [Apollo Studio Explorer](https://www.apollographql.com/docs/studio/explorer/). It’s Apollo’s web IDE for creating, running, and managing your GraphQL operations. 

### Write & execute a Rails-GraphQL query with GraphiQL

We are going to add more information to our Rails GraphQL API so we can write our first GraphQL query in our Rails project. 

We’re going to remove some of the example content and add a field called :comments in the `query_type.rb` file, so we can get all the comments returned. Notice the new comments method added here. Each field type contains a name (comments), a result type/options ([Types::CommentType], and :null is required and set to true or false. The description is optional but good to have since it helps with documentation. 

```ruby
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
  end
end
```

We now want to generate the CommentType using the GraphQL Ruby gem. In your console, enter the following command:
  
```bash 
rails g graphql:object comment
```

The response should look like this if successful:
```bash
create  app/graphql/types/comment_type.rb
```

Now we need to update the `types/comment_type.rb` file to include the fields that have a type and nullable option. 

```ruby
module Types
  class CommentType < Types::BaseObject
    field :id, ID, null: false
    field :comment, String, null: false
    field :person, Types::PersonType, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false
    field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
  end
end
``` 

You might be thinking, how does this all work? It looks for the method with the same name defined in the class time (thanks rails magic!) Now let’s do the same thing, but for the PersonType. 

```bash
rails g graphql:object person
```

Again, if successful, you should see the following response:
```bash
create  app/graphql/types/person_type.rb
```

Now we need to update the `types/person_type.rb` file to include a `full_name` method and `full_name` field:

```ruby
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
  end
end
```

We now have enough code to start your rails server. Run `rails s` in your console and open up GraphiQL: [http://localhost:3000/graphiql](http://localhost:3000/graphiql) in your web browser. In GraphiQL run the following query. We can type in a query to run with the data we added to our db/seeds file and get a response back.

Start the server:
```bash
rails s
```

The output should look like:
```bash
=> Booting Puma
=> Rails 7.0.4.3 application starting in development 
=> Run `bin/rails server --help` for more startup options
Puma starting in single mode...
* Puma version: 5.6.5 (ruby 3.2.2-p53) ("Birdie's Version")
*  Min threads: 5
*  Max threads: 5
*  Environment: development
*          PID: 38587
* Listening on http://127.0.0.1:3000
* Listening on http://[::1]:3000
Use Ctrl-C to stop
```

Now go to [http://localhost:3000/graphiql](http://localhost:3000/graphiql) and run the following query:

```graphql
query {
  comments {
    id
    comment
    person {
      firstName
      lastName
      email
      createdAt
    }
  }
}
```

The response should look similar to this:
```json
{
  "data": {
    "comments": [
      {
        "id": "cfd6f460-edae-4e88-88d1-a882b38ee5a1",
        "comment": "This is a comment from Matt Groff",
        "person": {
          "firstName": "Matt",
          "lastName": "Groff",
          "email": "matt@umbrage.com",
          "createdAt": "2023-04-23T02:44:22Z"
        }
      },
      {
        "id": "e5821082-6f31-44cb-8b97-2f590a55ba29",
        "comment": "This is another comment from Matt Groff",
        "person": {
          "firstName": "Matt",
          "lastName": "Groff",
          "email": "matt@umbrage.com",
          "createdAt": "2023-04-23T02:44:22Z"
        }
      }
    ]
  }
}
```

How's this all work? How is Rails doing all this?

```bash
  Person Load (0.8ms)  SELECT "people".* FROM "people"
  Comment Load (0.5ms)  SELECT "comments".* FROM "comments" WHERE "comments"."person_id" = $1  [["person_id", "49f53c0b-3c55-47d2-8842-9b7bffeb3d1b"]]
Completed 200 OK in 24ms (Views: 0.2ms | ActiveRecord: 6.6ms | Allocations: 19936)
```

The GraphQL gem created the GraphqlController for us. It is where requests are sent to. Within this file, you can see that the execute method/action does a lot of work for us. 

```ruby
def execute
    variables = prepare_variables(params[:variables])
    query = params[:query]
    operation_name = params[:operationName]
    context = {
    }
    result = TaypiSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
end
```

We did a GraphQL query with Ruby on Rails! We are now fetching person/people along with comments. 

### More TypeDef and Resolvers
I wanted to add a "person" query which takes in an ID of the `Person` and returns that `Person` object. We can do this by adding a new field to the `QueryType` and a new resolver. 

```ruby
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
```

And inside of `PersonType` I added a `comments` field to return all the comments for a person. 

```ruby
    # Add a field to the PersonType that returns a list of comments
    field :comments, [Types::CommentType], null: false
    def comments
      object.comments
    end
```

Now I can query a person like so:
  
```graphql  
query {
  person(id: "3c4ceab0-1b13-4fe1-a4bb-ea4ec8b042f8") {
    id
    firstName
    lastName
    email
    comments {
      id
      comment
    }
  }
}
```

If I also want to ask for multiple people, let's add to the `QueryType` once again:
```ruby
    # Ask for a list of people
    field :people,
    [Types::PersonType],
    null: false,
    description: "Return a list of people"

    def people
      Person.all
    end
```

Now I can query a list of people like so:
```graphql
query {
  people {
    id
    firstName
    lastName
    email
    comments {
      id
      comment
    }
  }
}
```

Let's add a Mutation to add a new `Comment` to a `Person`. Go to `mutation_type.rb` and add the following to the class MutationType like so:
  
  ```ruby
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

  end
end
```

This creates a new mutation called `addComment` that takes in a `comment` and `person_id` and returns a `Comment`.

```graphql
addComment(
comment: String!
personId: ID!
): Comment!
```

Now we can add a new comment to a person like so:
```graphql
mutation {
  addComment(
    comment: "This is a new comment"
    personId: "3c4ceab0-1b13-4fe1-a4bb-ea4ec8b042f8"
  ) {
    id
    comment
    person {
      id
      firstName
      lastName
      email
      comments {
        id
        comment
        createdAt
      }
    }
  }
}
```

Let's create a new person. Go to `mutation_type.rb` and add the following to the class MutationType like so:
  
  ```ruby
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
```

This creates a new mutation called `addPerson` that takes in a `first_name`, `last_name`, `email`, `job_title`, and `avatar` and returns a `Person`.

```graphql
addPerson(
firstName: String!
lastName: String!
email: String!
jobTitle: String!
avatar: String!
): Person!
```

Now we can add a new person like so:
```graphql
mutation {
  addPerson(
    firstName: "Jane"
    lastName: "Doe"
    email: "jane@umbrage.com"
    jobTitle: "Senior Design Crafter"
    avatar: "https://www.gravatar.com/avatar/df56f48c7a057d2b45915c96011aaf42"
  ) {
    id
    firstName
    lastName
    email
    jobTitle
    avatar
  }
}
```

### Disable CORS/Cross-Site Request Forgery
To disable CSRF protection for your GraphQL endpoint, you can modify your `app/controllers/application_controller.rb` file as follows:

```ruby
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception, unless: :graphql_controller?

  private

  def graphql_controller?
    controller_name == 'graphql'
  end
end

```


### Dockerize and Deploy

I wanted to dockerize and deploy this app. I followed this [tutorial](https://www.koyeb.com/tutorials/dockerize-deploy-and-run-a-ruby-on-rails-app) to do so.

Create a `Dockerfile` in the root directory of the project. 

```dockerfile
FROM ruby:3.2.2-alpine
WORKDIR /app
COPY . .
RUN apk add --no-cache build-base tzdata nodejs postgresql-dev
RUN gem install bundler
RUN bundle install
ENV RAILS_ENV=production
RUN bundle exec rails assets:precompile
EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
```

Build the docker image to make sure it works.

```bash
docker build -t rails-graphql .
```

If successful, you should see something like this:

```bash
[+] Building 37.2s (13/13) FINISHED                                                                            
 => [internal] load build definition from Dockerfile                                                      0.0s
 => => transferring dockerfile: 32B                                                                       0.0s
 => [internal] load .dockerignore                                                                         0.0s
 => => transferring context: 2B                                                                           0.0s
 => [internal] load metadata for docker.io/library/ruby:3.2.2-alpine                                      1.1s
 => [auth] library/ruby:pull token for registry-1.docker.io                                               0.0s
 => [internal] load build context                                                                         0.1s
 => => transferring context: 209.06kB                                                                     0.1s
 => [1/7] FROM docker.io/library/ruby:3.2.2-alpine@sha256:697038d90aa973dfa8bb3613f3d57d58b38bdf7957b83a  0.0s
 => CACHED [2/7] WORKDIR /app                                                                             0.0s
 => [3/7] COPY . .                                                                                        0.3s
 => [4/7] RUN apk add --no-cache build-base tzdata nodejs postgresql-dev                                 11.5s
 => [5/7] RUN gem install bundler                                                                         1.7s
 => [6/7] RUN bundle install                                                                             18.1s 
 => [7/7] RUN bundle exec rails assets:precompile                                                         2.5s 
 => exporting to image                                                                                    1.9s 
 => => exporting layers                                                                                   1.9s 
 => => writing image sha256:7d437c9e05b4cc85f17d7f23acd11f03af3a3f98bd38306f15b4f62ad5d3a02f              0.0s 
 => => naming to docker.io/library/rails-graphql           
 ```

Run the docker image to make sure it works.
  
```bash
docker run -p 3000:3000 \
  -e DATABASE_URL="postgres://postgres:mysecretpassword@localhost:5432/rails_graphql_development" \
  rails-graphql
```

In your terminal create a secret with `rails secret`. Copy the secret.
  
```bash
rails secret
```

We need to add a `secret_key_base` for the production environment in order to deploy. Edit the `config/environments/production.rb` file and add the following line:

```ruby
config.secret_key_base = <your copied secret here>
```

NOTE: If we were using any encrypted data this would be a bad security practice for obvious reasons. We can and should use an ENV variable for this in production deployments.

### Resources

[using-graphql-with-ruby-on-rails](https://www.apollographql.com/blog/community/backend/using-graphql-with-ruby-on-rails/)

[dockerize-deploy-and-run-a-ruby-on-rails-app](https://www.koyeb.com/tutorials/dockerize-deploy-and-run-a-ruby-on-rails-app)